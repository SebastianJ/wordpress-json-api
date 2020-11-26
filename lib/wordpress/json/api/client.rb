# frozen_string_literal: true

module Wordpress
  module Json
    module Api

      class Client
        attr_accessor :url, :configuration, :connection, :headers
  
        def initialize(url, configuration: ::Wordpress::Json::Api.configuration, options: {})
          self.configuration = configuration
          set_url(url)
          set_connection
        end

        def set_url(url)
          self.url = url.include?("/wp-json/wp/v#{self.configuration.version}/") ? url : "#{url.gsub(/\/$/i, '')}/wp-json/wp/v#{self.configuration.version}/"
        end
  
        def set_connection
          self.connection = ::Faraday.new(url) do |builder|
            if configuration.faraday.fetch(:timeout, nil)
              builder.options[:timeout]         =   configuration.faraday.fetch(:timeout, nil)
            end
            if configuration.faraday.fetch(:open_timeout, nil)
              builder.options[:open_timeout]    =   configuration.faraday.fetch(:open_timeout, nil)
            end
  
            builder.headers = headers if headers && !headers.empty?
  
            builder.request :json
  
            if configuration.verbose
              builder.response :logger, ::Logger.new(STDOUT), bodies: true
            end
            builder.response :json, content_type: /\bjson$/
  
            builder.use ::FaradayMiddleware::FollowRedirects, limit: 3
  
            builder.adapter configuration.faraday.fetch(:adapter, ::Faraday.default_adapter)
          end
        end
  
        def get(path, params: {})
          request(path, params: params)&.fetch(:body, nil)
        end

        def request(path, params: {})
          resp = connection.get(path) do |request|
            if headers && !headers.empty?
              request.headers = connection.headers.merge(headers)
            end
            request.params = params if params && !params.empty?
          end

          response(resp)
        end

        def all(path, params: {})
          page              =   1
          params.merge!(per_page: 100)
          responses         =   []
          continue          =   false

          begin
            params.merge!(page: page)

            begin
              resp          =   request(path, params: params)
              body          =   resp&.fetch(:body, nil)
              headers       =   resp&.fetch(:headers, {})
              total_pages   =   headers.fetch('x-wp-totalpages', 0)&.to_i

              if (body && body.is_a?(Array) && body.any?)
                responses   =   responses | body
                page       +=   1
              end

              continue      =   (page <= total_pages)
            rescue ::Wordpress::Json::Api::Error => exception
              continue      =   false
            end
          end while continue

          return responses
        end

        def response(resp)
          if resp.success?
            body  = resp&.body
  
            error_code = (body && body.is_a?(Hash) && !body.fetch('code', nil).to_s.empty?) ? body.fetch('code', nil).to_s : nil
            unless error_code.to_s.empty?
              raise ::Wordpress::Json::Api::Error, error_code
            end

            headers = resp&.env&.response_headers
  
            return {body: body, headers: headers}
          else
            raise ::Wordpress::Json::Api::Error, "Failed to send request to #{self.url}"
          end
        end
        
      end

    end
  end
end
