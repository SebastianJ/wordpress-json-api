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
  
            builder.use ::FaradayMiddleware::FollowRedirects, limit: 10
  
            builder.adapter configuration.faraday.fetch(:adapter, ::Faraday.default_adapter)
          end
        end
  
        def get(path, params: {})
          resp = connection.get(path) do |request|
            if headers && !headers.empty?
              request.headers = connection.headers.merge(headers)
            end
            request.params = params if params && !params.empty?
          end

          response(resp)
        end

        def response(resp)
          if resp.success?
            resp  = resp&.body
  
            error_code = (resp && resp.is_a?(Hash) && !resp.fetch('code', nil).to_s.empty?) ? resp.fetch('code', nil).to_s : nil
            unless error_code.to_s.empty?
              raise ::Wordpress::Json::Api::Error, error_code
            end
  
            resp
          else
            raise ::Wordpress::Json::Api::Error, "Failed to send request to #{self.url}"
          end
        end
        
      end

    end
  end
end
