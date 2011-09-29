require "sprockets"

module Machined
  class Sprocket < Sprockets::Environment
    # Default options for a Machined sprocket.
    DEFAULT_OPTIONS = {
      :root   => ".",
      :assets => false
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
      use_all_templates unless config[:assets]
    end
    
    # Loops through the available Tilt templates
    # and registers them as processor engines for
    # Sprockets. By default, Sprockets cherry picks
    # templates that work for web assets. We need to
    # allow use of Haml, Markdown, etc.
    def use_all_templates
      Utils.available_templates.each do |ext, template|
        next if engines(ext)
        register_engine ext, template
      end
    end
  end
end
