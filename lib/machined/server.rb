require 'active_support/file_update_checker'
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

      if machined.environment.development?
        # Configure watchable files
        files = []
        files << machined.config_path if machined.config_path.exist?

        # Configure watchable dirs
        dirs = {}
        dirs[machined.lib_path.to_s] = [:rb] if machined.lib_path.exist?

        # Setup file watching using ActiveSupport::FileUpdateChecker
        @reloader = ActiveSupport::FileUpdateChecker.new(files, dirs) do
          machined.reload
          reload
        end
      end

      reload
    end

    # Using the URLMap, determine which sprocket
    # should handle the request and then...let it
    # handle it.
    def call(env)
      @reloader.execute_if_updated if machined.environment.development?
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
        app.use Middleware::RootIndex
        app.run Rack::URLMap.new(sprockets_map)
      end
    end

    # Maps the Machined environment's current
    # sprockets for use with `Rack::URLMap`.
    def sprockets_map # :nodoc:
      {}.tap do |map|
        machined.sprockets.each do |sprocket|
          next unless sprocket.compile?
          map[sprocket.config.url] = sprocket
        end
      end
    end
  end
end
