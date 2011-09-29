require "sprockets"

module Machined
  class Context < Sprockets::Context
    include LocalsHelpers
    
    # Returns the main Machined environment instance.
    def machined
      environment.machined
    end
    
    # Returns the configuration of the Machined environment.
    def config
      machined.config
    end
  end
end
