require "rack/urlmap"

module Machined
  class Server
    
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    # Creates a new Rack server that will serve
    # up the processed files.
    def initialize(machined)
      @machined = machined
      remap
    end
    
    # Using the URLMap, determine which sprocket
    # should handle the request and then...let it
    # handle it.
    def call(env)
      @url_map.call(env)
    end
    
    #
    def remap
      map = {}
      machined.sprockets.each do |sprocket|
        next if sprocket.config[:compile] == false || 
        map[sprocket.config[:url]] = sprocket
      end
      @url_map = Rack::URLMap.new map
    end
  end
end
