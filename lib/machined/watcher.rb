require 'pathname'
require 'set'

module Machined
  # Reloader triggers a reload of the Machined
  # environment whenever a configuration or lib
  # file is changed.
  class Watcher
    class File # :nodoc:
      # The path to the file to watch.
      attr_reader :path
      
      # The latest modified time of the file.
      attr_reader :mtime
      
      # Creates a new Watcher.
      def initialize(path)
        @path = path
        update
      end
      
      # Returns true if the file has been updated or removed
      def updated?
        path.exist? && path.mtime > mtime
      end
      
      # Update the latest modified time.
      def update
        @mtime = path.mtime
      end
    end
    
    # A list of paths to watch for changes.
    attr_reader :files
    
    # Creates a new Reloader.
    def initialize(paths = nil)
      @files = Set.new
      watch *paths unless paths.nil?
    end
    
    # Check for any changes, and reload
    # the environment if necessary. Returns true
    # if the environment is reloaded.
    def perform
      updated_files = files.select(&:updated?)
      updated       = !updated_files.empty?
      
      if updated
        updated_files.each do |file|
          $LOADED_FEATURES.delete(file.path.to_s)
          file.update
        end
        yield if block_given?
      end
      
      updated
    end
    
    # Watch the given path if it exists.
    def watch(*paths)
      paths.each do |path|
        path   = Pathname.new(path).expand_path
        files << File.new(path) if path.file?
      end
    end
  end
end
