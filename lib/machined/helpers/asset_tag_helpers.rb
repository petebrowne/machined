require "active_support/concern"

module Machined
  module Helpers
    module AssetTagHelpers
      extend  ActiveSupport::Concern
      include Padrino::Helpers::AssetTagHelpers
      
      # Returns a path to an asset, either in the output path
      # or in the assets environment. It will default to appending
      # the old-school timestamp.
      def asset_path(kind, source)
        AssetPath.new(machined, source, kind).to_s
      end
      
      # Handles creating the full path, with digest or timestamp,
      # to the asset - whether it's just a normal file in the
      # output path or if it's an asset in the assets environment.
      class AssetPath
        #
        attr_reader :machined
        
        #
        attr_reader :source
        
        #
        attr_reader :kind
        
        #
        def initialize(machined, source, kind)
          @machined = machined
          @source   = source.to_s
          @kind     = kind
        end
        
        # Determines if the path is a URI.
        def uri?
          source =~ %r(^[-a-z]+://|^cid:|^//)
        end
        
        # Determines if the path is already
        # absolute.
        def absolute?
          source =~ %r(^/)
        end
        
        # Determines if this is an asset in the
        # assets environment.
        def asset?
          !!asset
        end
        
        #
        def to_s
          return source if uri?
          path = rewrite_extension(source)
          path = rewrite_base_path(path)
          path = rewrite_timestamp(path)
          path
        end
        
        protected
        
        # Returns the asset for the current source path
        # if it exists.
        def asset
          return @asset if defined?(@asset)
          @asset = machined.assets.resolve(source) do |found|
            machined.assets[found]
          end
          @asset
        end
        
        # Returns the mtime for the given path.
        # Uses the assets environments mtime, if it is
        # an asset.
        def mtime(path)
          if asset?
            asset.mtime
          else
            output_path = File.join(machined.output_path.to_s, path)
            File.exist?(output_path) ? File.mtime(output_path) : nil
          end
        end
        
        # Returns the name of the directory the asset
        # should be in, based on the +kind+, if it is
        # not an asset.
        def directory
          case kind
          when :css then "stylesheets"
          when :js  then "javascripts"
          else
            kind.to_s
          end
        end
        
        # 
        def rewrite_extension(path)
          return path unless [ :css, :js ].include?(kind)
          path << ".#{kind}" unless path =~ /\.#{kind}/
          path
        end
        
        #
        def rewrite_base_path(path)
          if absolute?
            path
          elsif asset?
            File.join(machined.assets.config[:url], asset.logical_path)
          else
            File.join("/#{kind}", path)
          end
        end
        
        #
        def rewrite_timestamp(path)
          if timestamp = mtime(path)
            path << "?#{timestamp.to_i}" unless path =~ /\?\d+$/
          end
          path
        end
      end
    end
  end
end