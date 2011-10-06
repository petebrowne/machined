require "fileutils"

module Machined
  class StaticCompiler
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    # Creates a new instance, which will compile
    # the assets to the given +output_path+.
    def initialize(machined)
      @machined = machined
    end
    
    # Loop through and compile each available
    # asset to the appropriate output path.
    def compile
      compiled_assets = {}
      machined.sprockets.each do |sprocket|
        next unless sprocket.compile?
        sprocket.each_logical_path do |logical_path|
          url = File.join(sprocket.config.url, logical_path)
          next unless compiled_assets[url].nil? && compile?(url)
          
          if asset = sprocket.find_asset(logical_path)
            compiled_assets[url] = write_asset(asset)
          end
        end
      end
      compiled_assets
    end
    
    # Determines if we should precompile the asset
    # with the given url. By default, we skip over any
    # files that begin with "_", like partials.
    def compile?(url)
      File.basename(url) !~ /^_/
    end
    
    # Writes the asset to its destination, also
    # writing a gzipped version if necessary.
    def write_asset(asset)
      filename = path_for(asset)
      FileUtils.mkdir_p File.dirname(filename)
      asset.write_to filename
      asset.write_to "#{filename}.gz" if gzip?(filename)
      asset.digest
    end
    
    protected
    
    # Gets the full output path for the given asset.
    # If it's supposed to include a digest, it will return the
    # digest_path.
    def path_for(asset) # :nodoc:
      path = digest?(asset) ? asset.digest_path : asset.logical_path
      File.join(machined.output_path, asset.environment.config.url, path)
    end
    
    # Determines if we should use the digest_path for the given
    # asset.
    def digest?(asset) # :nodoc:
      machined.config.digest_assets && asset.environment.config.assets
    end
    
    # Determines if we should gzip the asset.
    def gzip?(filename) # :nodoc:
      machined.config.gzip_assets && filename =~ /\.(css|js)$/
    end
  end
end
