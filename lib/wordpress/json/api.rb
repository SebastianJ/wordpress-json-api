require 'faraday'
require 'faraday_middleware'
require 'logger'

require "wordpress/json/api/version"
require "wordpress/json/api/configuration"
require "wordpress/json/api/client"

module Wordpress
  module Json
    module Api
      class << self
        attr_writer :configuration
  
        def configuration
          @configuration ||= ::Wordpress::Json::Api::Configuration.new
        end
  
        def reset
          @configuration = ::Wordpress::Json::Api::Configuration.new
        end
  
        def configure
          yield(configuration)
        end
      end
  
      class Error < StandardError; end
    end
  end
end
