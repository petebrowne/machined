require 'construct'
require 'rack/test'
require 'unindent'
require 'machined'
require 'sprockets'
require 'crush'
require 'slim'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Construct::Helpers
  config.include Machined::SpecHelpers
end
