# frozen_string_literal: true

module Wordpress
  module Json
    module Api

      class Configuration
        attr_accessor :version, :faraday, :verbose
  
        def initialize
          self.version = 2

          self.faraday = {
            adapter: :net_http,
            timeout: 120,
            open_timeout: 60
          }
  
          self.verbose = false
        end
      end

    end
  end
end
