require "bundler"
Bundler.require :default, :development
require "test-construct"
require "rack/test"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Construct::Helpers
end
