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
            timeout: 60,
            open_timeout: 30,
            #user_agent: 'ENTER_A_CUSTOM_USER_AGENT_HERE'
          }
  
          self.verbose = false
        end
      end

    end
  end
end
