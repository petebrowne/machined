require 'rack'

module Machined
  class Server
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    # Creates a new Rack server that will serve
    # up the processed files.
    def initialize(machined)
      @machined = machined
      
      if watch_for_changes?
        @watcher = Watcher.new
        @watcher.watch machined.config_path
        @watcher.watch *Dir[machined.lib_path.join('**/*.rb')]
      end
      
      reload
    end
    
    # Using the URLMap, determine which sprocket
    # should handle the request and then...let it
    # handle it.
    def call(env)
      @watcher.perform do
        machined.reload
        reload
      end if watch_for_changes?
      
      @app.call(env)
    end
    
    # Rebuilds the Rack app with the current Machined
    # configuration.
    def reload
      @app = to_app
    end
    
    protected
    
    # Creates a Rack app with the current Machined
    # environment configuration.
    def to_app # :nodoc:
      Rack::Builder.new.tap do |app|
        app.use Middleware::Static, machined.output_path
        app.run Rack::URLMap.new(map)
      end
    end
    
    # Maps the Machined environment's current
    # sprockets for use with `Rack::URLMap`.
    def map # :nodoc:
      {}.tap do |map|
        machined.sprockets.each do |sprocket|
          next unless sprocket.compile?
          map[sprocket.config.url] = sprocket
        end
      end
    end
    
    # Returns true if we should watch for
    # file changes (in development)
    def watch_for_changes? # :nodoc:
      machined.config.environment == 'development'
    end
  end
end
