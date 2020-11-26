require "bundler/setup"
require "wordpress/json/api"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

raise ArgumentError, "You have to specify a URL using e.g. URL=https://some.random.url in order to run specs" if ENV.fetch('URL', nil).to_s.empty?
