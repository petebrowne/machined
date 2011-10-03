require "fileutils"

module Machined
  class StaticCompiler
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    # The root path where the files should be
    # generated.
    attr_reader :output_path
    
    # Creates a new instance, which will compile
    # the assets to the given +output_path+.
    def initialize(machined, output_path)
      @machined    = machined
      @output_path = output_path
    end
    
    # Loop through and compile each available
    # asset to the appropriate output path.
    def compile
      compiled_assets = {}
      machined.sprockets.each do |sprocket|
        next unless sprocket.compile?
        sprocket.each_logical_path do |logical_path|
          url = File.join(sprocket.config[:url], logical_path)
          next unless compiled_assets[url].nil? && compile?(url)
          if asset = sprocket[logical_path]
            compiled_assets[url] = compile_asset(asset, url)
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
    
    protected
    
    def compile_asset(asset, url)
      filename = File.join(output_path, url)
      FileUtils.mkdir_p File.dirname(filename)
      asset.write_to filename
      asset.digest
    end
  end
end
