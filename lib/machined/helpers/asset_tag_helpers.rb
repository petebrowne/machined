module Machined
  module Helpers
    module AssetTagHelpers
      # Override asset_path to also work with the
      # Padrino::Helpers::AssetTagHelpers API.
      def asset_path(source, options = {})
        case source
        when :css
          path_to_asset options, :dir => "stylesheets", :ext => "css"
        when :images
          path_to_asset options, :dir => "images"
        when :js
          path_to_asset options, :dir => "javascripts", :ext => "js"
        else
          path_to_asset source, options
        end
      end
    end
  end
end