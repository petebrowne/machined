require "sprockets"

module Machined
  class Sprocket < Sprockets::Environment
    
    # Default options for a Machined sprocket.
    DEFAULT_OPTIONS = {
      :root => "."
    }.freeze
    
    # A reference to the Machined environment which
    # created this instance.
    attr_reader :machined
    
    # A reference to the configuration.
    attr_reader :config
    
    # Creates a new Machined sprocket. The API is
    # a bit different than `Sprockets::Environment` to
    # allow for per-Sprockets-environment configuration
    # and to keep a reference to the Machined environment.
    def initialize(machined, options = {})
      @config = DEFAULT_OPTIONS.dup.merge options
      super config[:root]
      @machined = machined
      @context_class = Class.new Context
    end
  end
end
