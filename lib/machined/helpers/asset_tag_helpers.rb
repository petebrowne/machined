require "active_support/concern"

module Machined
  module Helpers
    module AssetTagHelpers
      extend  ActiveSupport::Concern
      include Padrino::Helpers::AssetTagHelpers
      
      #
      def asset_path(kind, source)
        super
      end
    end
  end
end