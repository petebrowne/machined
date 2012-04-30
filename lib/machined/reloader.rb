require 'pathname'
require 'set'

module Machined
  class Reloader
    #
    class Path
      # The path to the file to watch.
      attr_reader :path
      
      # The latest modified time of the file.
      attr_reader :mtime
      
      #
      def initialize(path)
        @path = Pathname.new(path).expand_path
        update
      end
      
      # Returns true if the file has been updated or removed
      def updated?
        result = path.mtime > mtime
        update
        result
      end
      
      # Update the latest modified time.
      def update
        @mtime = path.mtime
      end
    end
    
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    #
    attr_reader :paths
    
    #
    def initialize(machined)
      @machined = machined
      @paths    = Set.new
      
      watch machined.config_path
      Dir.glob(machined.root.join('lib/**/*.rb')).each do |path|
        watch path
      end
    end
    
    #
    def perform
      updated_paths = paths.select(&:updated?)
      !updated_paths.empty?
    end
    
    def watch(path)
      @paths << Path.new(path)
    end
  end
end
