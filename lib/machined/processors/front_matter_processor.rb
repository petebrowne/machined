require 'yaml'
require 'tilt'

module Machined
  module Processors
    class FrontMatterProcessor < Tilt::Template
      # The Regexp that separates the YAML
      # front matter from the content.
      FRONT_MATTER_PARSER = /
        (
          \A\s*       # Beginning of file
          ^---\s*$\n* # Start YAML Block
          (.*?)\n*    # YAML data
          ^---\s*$\n* # End YAML Block
        )
        (.*)\Z        # Rest of File
      /mx

      # See `Tilt::Template#prepare`.
      def prepare
      end

      # See `Tilt::Template#evaluate`.
      def evaluate(context, locals = {}, &block)
        output = data
        if FRONT_MATTER_PARSER.match data
          locals         = YAML.load $2
          context.locals = locals if locals
          output         = $3
        end
        output
      end
    end
  end
end
