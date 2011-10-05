require "padrino-helpers"
require "sprockets"

module Machined
  class Context < Sprockets::Context
    include LocalsHelpers
    include OutputHelpers
    include RenderHelpers
    include Padrino::Helpers::OutputHelpers
    include Padrino::Helpers::TagHelpers
    include Padrino::Helpers::AssetTagHelpers
    include Padrino::Helpers::FormHelpers
    include Padrino::Helpers::FormatHelpers
    include Padrino::Helpers::NumberHelpers
    include Padrino::Helpers::TranslationHelpers
    
    # Override initialize to add helpers
    # from the Machined environment.
    def initialize(*args) # :nodoc:
      super
      add_machined_helpers
    end
    
    # Returns the main Machined environment instance.
    def machined
      environment.machined
    end
    
    # Returns the configuration of the Machined environment.
    def config
      machined.config
    end
    
    protected
    
    # Loops through the helpers added to the Machined
    # environment and adds them to the Context. Supports
    # blocks and Modules.
    def add_machined_helpers # :nodoc:
      machined.context_helpers.each do |helper|
        case helper
        when Proc
          instance_eval &helper
        when Module
          extend helper
        end
      end
    end
  end
end
