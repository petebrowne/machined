require "sprockets"

module Machined
  class Context < Sprockets::Context
    # Returns the main Machined environment instance
    def machined
      environment.machined
    end
  end
end
