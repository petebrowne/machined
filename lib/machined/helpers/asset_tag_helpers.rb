require "active_support/concern"

module Machined
  module Helpers
    module AssetTagHelpers
      extend  ActiveSupport::Concern
      include Padrino::Helpers::AssetTagHelpers
      
      # Pattern for checking if a given path
      # is an external URI.
      URI_MATCH = %r(^[-a-z]+://|^cid:|^//)
      
      # Returns a path to an asset, either in the output path
      # or in the assets environment. It will default to appending
      # the old-school timestamp.
      def asset_path(kind, source)
        return source if source =~ URI_MATCH
        
        # Append extension if necessary.
        if [:css, :js].include?(kind)
          source << ".#{kind}" unless source =~ /\.#{kind}$/
        end
        
        # If the source points to an asset in the assets
        # environment use `AssetPath` to generate the full path.
        machined.assets.resolve(source) do |path|
          return AssetPath.new(machined, machined.assets.find_asset(path)).to_s
        end
        
        # Default to using a basic `FilePath` to generate the
        # full path.
        FilePath.new(machined, source, kind).to_s
      end
      
      # `FilePath` generates a full path for a regular file
      # in the output path. It's used by #asset_path to generate
      # paths when using asset tags like #javascript_include_tag,
      # #stylesheet_link_tag, and #image_tag
      class FilePath
        # A reference to the Machined environment.
        attr_reader :machined
        
        # The path from which to generate the full path to the asset.
        attr_reader :source
        
        # The expected kind of file (:css, :js, :images).
        attr_reader :kind
      
        #
        def initialize(machined, source, kind)
          @machined = machined
          @source   = source.to_s
          @kind     = kind
        end
        
        # Returns the full path to the asset, complete with
        # timestamp.
        def to_s
          path = rewrite_base_path(source)
          path = rewrite_timestamp(path)
          path
        end
        
        protected
        
        # Prepends the base path if the path is not
        # already an absolute path.
        def rewrite_base_path(path) # :nodoc:
          if path =~ %r(^/)
            path
          else
            File.join(base_path, path)
          end
        end
        
        # Appends an asset timestamp based on the
        # modification time of the asset.
        def rewrite_timestamp(path) # :nodoc:
          if timestamp = mtime(path)
            "#{path}?#{timestamp.to_i}" unless path =~ /\?\d+$/
          else
            path
          end
        end
        
        # Returns the expected base path for this asset.
        def base_path # :nodoc:
          case kind
          when :css then "/stylesheets"
          when :js  then "/javascripts"
          else
            "/#{kind}"
          end
        end
        
        # Returns the mtime for the given path (relative to
        # the output path). Returns nil if the file doesn't exist.
        def mtime(path) # :nodoc:
          output_path = File.join(machined.output_path.to_s, path)
          File.exist?(output_path) ? File.mtime(output_path) : nil
        end
      end
      
      # `AssetPath` generates a full path for an asset
      # that exists in Machined's `assets` environment.
      class AssetPath < FilePath
        attr_reader :asset
        
        def initialize(machined, asset)
          @machined = machined
          @asset    = asset
          @source   = digest? ? asset.digest_path : asset.logical_path
        end
        
        protected
        
        def rewrite_timestamp(path)
          digest? ? path : super
        end
        
        def digest?
          machined.config.digest_assets
        end
        
        def base_path
          machined.assets.config.url
        end
        
        def mtime(path)
          asset.mtime
        end
      end
    end
  end
end