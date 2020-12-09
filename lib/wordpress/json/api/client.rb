# frozen_string_literal: true

module Wordpress
  module Json
    module Api
      class Client
        attr_accessor :url, :configuration, :connection, :headers
  
        def initialize(url, configuration: ::Wordpress::Json::Api.configuration, options: {})
          self.configuration = configuration
          set_url(url)
          set_headers
          set_connection
        end

        def set_url(url)
          self.url = url.include?("/wp-json/wp/v#{self.configuration.version}/") ? url : "#{url.gsub(/\/$/i, '')}/wp-json/wp/v#{self.configuration.version}/"
        end

        def set_headers
          self.headers                      ||=   {}
          set_user_agent
        end

        def set_user_agent
          user_agent                          =   self.configuration.faraday.fetch(:user_agent, nil)
          
          if user_agent
            if user_agent.is_a?(String)
              self.headers["User-Agent"]      =   user_agent
            elsif user_agent.is_a?(Array)
              self.headers["User-Agent"]      =   user_agent.sample
            elsif user_agent.is_a?(Proc)
              self.headers["User-Agent"]      =   user_agent.call
            end
          end
        end
  
        def set_connection
          self.connection = ::Faraday.new(url) do |builder|
            builder.options[:timeout]         =   configuration.faraday.fetch(:timeout, nil) if configuration.faraday.fetch(:timeout, nil)
            builder.options[:open_timeout]    =   configuration.faraday.fetch(:open_timeout, nil) if configuration.faraday.fetch(:open_timeout, nil)
  
            builder.headers = self.headers if self.headers && !self.headers.empty?
            builder.request :json
            builder.response :logger, ::Logger.new(STDOUT), bodies: true if configuration.verbose
            builder.response :json, content_type: /\bjson$/
            builder.use ::FaradayMiddleware::FollowRedirects, limit: 3
  
            builder.adapter configuration.faraday.fetch(:adapter, ::Faraday.default_adapter)
          end
        end
  
        def get(path, params: {}, headers: {})
          request(path, params: params, headers: headers)&.fetch(:body, nil)
        end

        def request(path, params: {}, headers: {}, retries: 3)
          response    =   nil

          begin
            resp      =   self.connection.get(path) do |request|
              request.headers = connection.headers.merge(headers) if headers && !headers.empty?
              request.params  = params if params && !params.empty?
            end
  
            response  =   process_response(resp)
          rescue => exception
            retries       -= 1
            retry if retries > 0
          end

          return response
        end

        def all(path, params: {}, headers: {})
          page              =   1
          params.merge!(per_page: 100)
          responses         =   []
          continue          =   false

          begin
            params.merge!(page: page)

            begin
              resp          =   request(path, params: params, headers: headers)
              body          =   resp&.fetch(:body, nil)
              resp_headers  =   resp&.fetch(:headers, {})
              total_pages   =   resp_headers&.fetch('x-wp-totalpages', 0)&.to_i

              if body && body.is_a?(Array) && body.any?
                responses   =   responses | body
                page       +=   1
              end

              continue      =   (!total_pages.nil? && page <= total_pages)
            rescue ::Wordpress::Json::Api::Error => exception
              continue      =   false
            end
          end while continue

          return responses
        end

        def process_response(resp)
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
