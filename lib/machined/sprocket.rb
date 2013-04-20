require 'ostruct'
require 'sprockets'
require 'sprockets-sass'

module Machined
  class Sprocket < Sprockets::Environment
    # Default options for a Machined sprocket.
    DEFAULT_OPTIONS = {
      :root    => '.',
      :assets  => false,
      :compile => true
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
      @machined = machined
      @config   = OpenStruct.new DEFAULT_OPTIONS.dup.merge(options)

      super config.root

      @context_class = Class.new Context
    end

    # Returns true, if this sprocket should be
    # compiled. Nine times out of ten, you will want
    # your sprocket compiled, but sometimes - like
    # the default views sprocket - it is used as
    # a uncompiled resource.
    def compile?
      config.compile && config.url
    end

    # Override to use Machined's Index
    def index
      Index.new(self)
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

    # Override the default Sprockets method which incorrectly returns '.htm'.
    def extension_for_mime_type(type) # :nodoc:
      return '.html' if type == 'text/html'
      super
    end
  end
end
