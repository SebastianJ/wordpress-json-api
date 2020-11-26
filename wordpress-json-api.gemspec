require_relative 'lib/wordpress/json/api/version'

Gem::Specification.new do |spec|
  spec.name          = "wordpress-json-api"
  spec.version       = Wordpress::Json::Api::VERSION
  spec.authors       = ["Sebastian Johnsson"]
  spec.email         = ["sebastian.johnsson@gmail.com"]

  spec.summary       = %q{Wordpress V2 JSON API client}
  spec.description   = %q{Wordpress V2 JSON API client}
  spec.homepage      = "https://github.com/SebastianJ/wordpress-json-api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SebastianJ/wordpress-json-api"
  spec.metadata["changelog_uri"] = "https://github.com/SebastianJ/wordpress-json-api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '>= 1.1.0'
  spec.add_dependency 'faraday_middleware', '>= 1.0.0'
end
