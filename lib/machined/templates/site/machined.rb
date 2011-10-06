require "bundler"
Bundler.require :default, config.environment.to_sym

if config.environment == "production"
  # Compress javascripts and stylesheets
  config.compress = true
  
  # Generate digests for assets URLs
  # config.digest_assets = true
end

helpers do
  # Define helper methods here
end
