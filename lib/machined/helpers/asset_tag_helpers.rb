module Machined
  module Helpers
    module AssetTagHelpers
      # Override asset_path to also work with the
      # Padrino::Helpers::AssetTagHelpers API.
      def asset_path(source, options = {})
        case source
        when :css
          path_to_asset options, :dir => 'stylesheets', :ext => 'css'
        when :images
          path_to_asset options, :dir => 'images'
        when :js
          path_to_asset options, :dir => 'javascripts', :ext => 'js'
        else
          path_to_asset source, options
        end
      end
      
      # Redefine image_path to work with Sprockets::Helpers.
      def image_path(source, options = {})
        asset_path source, { :dir => 'images' }.merge(options)
      end
    end
  end
end