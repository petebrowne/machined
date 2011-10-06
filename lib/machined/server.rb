require "rack"

module Machined
  class Server
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    # Creates a new Rack server that will serve
    # up the processed files.
    def initialize(machined)
      @machined = machined
      @files    = Rack::File.new(machined.output_path)
      remap
    end
    
    # Using the URLMap, determine which sprocket
    # should handle the request and then...let it
    # handle it.
    def call(env)
      response = @url_map.call(env)
      response = @files.call(env) if response.first == 404
      response
    end
    
    # Remaps the Machined environment's current
    # sprockets using `Rack::URLMap`.
    def remap
      map = {}
      machined.sprockets.each do |sprocket|
        next unless sprocket.compile?
        map[sprocket.config[:url]] = sprocket
      end
      @url_map = Rack::URLMap.new map
    end
  end
end
