require 'sprockets'

module Machined
  # We need to add accessors for the Machined
  # environment and the Sprocket's config to the
  # index, so the Context has access.
  class Index < Sprockets::Index
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
  
    # A reference to the configuration.
    attr_reader :config
    
    #
    def initialize(environment)
      @machined = environment.machined
      @config   = environment.config
      
      super
    end
  end
end
