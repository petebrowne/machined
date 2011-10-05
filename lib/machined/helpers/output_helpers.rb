require "active_support/concern"
require "active_support/memoizable"
require "tilt"

# We need to ensure that Tilt's ERB template uses
# the same output variable that Padrino's helpers expect.
Tilt::ERBTemplate.default_output_variable = "@_out_buf"

module Machined
  module Helpers
    module OutputHelpers
      extend ActiveSupport::Concern
      extend ActiveSupport::Memoizable
      
      # A hash of Tilt templates that support
      # capture blocks where the key is the name
      # of the template.
      CAPTURE_ENGINES = {
        "Tilt::HamlTemplate"   => :haml,
        "Tilt::ERBTemplate"    => :erb,
        "Tilt::ErubisTemplate" => :erubis,
        "Slim::Template"       => :slim
      }
      
      protected
      
      # Attempts to return the current engine based on
      # the processors for this file. This is used by
      # Padrino's helpers to determine which type of template
      # engine to use when capturing blocks.
      def current_engine
        processors = environment.attributes_for(self.pathname).processors
        processors or return
        processors.each do |processor|
          engine = CAPTURE_ENGINES[processor.to_s] and return engine
        end
        
        nil
      end
      memoize :current_engine
    end
  end
end
