require "ostruct"
require "pathname"
require "active_support/core_ext/hash/reverse_merge"

module Machined
  class Environment
    # Default options for a Machined environment.
    DEFAULT_OPTIONS = {
      :root        => ".",
      :config_path => "machined.rb",
      :output_path => "public",
      :asset_paths => %w(vendor/assets lib/assets assets),
      :assets_url  => "/assets",
      :pages_path  => "pages",
      :pages_url   => "/",
      :views_path  => "views",
      :layout      => "main"
    }.freeze
    
    # The global configuration for the Machined
    # environment.
    attr_reader :config
    
    # An array of the helpers added to the Context
    # through the `#helpers` method.
    attr_reader :context_helpers
    
    # When the Machined environment is compiling static files,
    # this will reference the `Machined::StaticCompiler` which handles
    # looping through the available files and generating them.
    attr_reader :static_compiler
    
    # A reference to the root directory the Machined
    # environment is run from.
    attr_reader :root
    
    # An `Array` of the Sprockets environments (actually `Machined::Sprocket`
    # instances) that are the core of a Machined environment.
    attr_reader :sprockets
    
    # When the Machined environment is used as a Rack server, this
    # will reference the actual `Machined::Server` instance that handles
    # the requests.
    attr_reader :server
    
    # Creates a new Machined environment. It sets up three default
    # sprockets:
    #
    #   * An assets sprocket similar to what you would use
    # in a Rails 3.1 app.
    #   * A pages sprocket which handles static HTML pages.
    #   * A views sprocket, which is not compiled, which is where
    # layouts and partials go.
    #
    def initialize(options = {})
      @config          = OpenStruct.new DEFAULT_OPTIONS.dup.merge(options)
      @root            = Pathname.new(config.root).expand_path
      @sprockets       = []
      @context_helpers = []
      
      # Create and append the default `assets` sprocket.
      # This sprocket mimics the asset pipeline in Rails 3.1.
      append_sprocket :assets, :assets => true, :url => config.assets_url do |assets|
        config.asset_paths.each do |asset_path|
          Utils.existent_directories(root.join(asset_path)).each do |path|
            assets.append_path path
          end
        end
      end
      
      # Create and append the default `pages` sprocket.
      # This sprocket is responsible for processing HTML pages,
      # and includes processors for wrapping pages in layouts and
      # reading YAML front matter.
      append_sprocket :pages, :url => config.pages_url do |pages|
        pages_path = root.join(config.pages_path)
        pages.append_path(pages_path) if pages_path.exist?
        
        pages.register_mime_type     "text/html", ".html"
        pages.register_preprocessor  "text/html", FrontMatterProcessor
        pages.register_postprocessor "text/html", LayoutProcessor
      end
      
      # Create and append the default `views` sprocket.
      # The files in this sprocket are not compiled. They are
      # meant to be resources for the other sprockets. For instance,
      # the layouts for the `pages` sprocket will be located here.
      append_sprocket :views, :compile => false do |views|
        views_path = root.join(config.views_path)
        views.append_path(views_path) if views_path.exist?
        
        views.register_mime_type "text/html", ".html"
      end
      
      # If there's a config file, execute with the scope of the
      # newly created Machined environment.
      config_file = root.join(config.config_path)
      instance_eval config_file.read if config_file.exist?
      
      yield self if block_given?
    end
    
    # Handles Rack requests by passing the +env+ to an instance
    # of `Machined::Server`.
    def call(env)
      @server ||= Server.new self, root.join(config.output_path)
      server.call(env)
    end
    
    # Loops through the available static files and generates them in
    # the output path.
    def compile
      @static_compiler ||= StaticCompiler.new self, root.join(config.output_path)
      static_compiler.compile
    end
    
    # Creates a Machined sprocket with the given +name+ and +options+
    # and appends it to the #sprockets list. This will also create
    # an accessor with the given name that references the created sprocket.
    #
    #   machined.append_sprocket :updates, :map => "/news" do |updates|
    #     updates.append_path "updates"
    #   end
    #   
    #   machined.updates              # => #<Machined::Sprocket...>
    #   machined.updates.config[:map] # => "/news"
    #   machined.updates.paths        # => [ ".../updates" ]
    #
    def append_sprocket(name, options = {}, &block)
      create_sprocket(name, options, &block).tap do |sprocket|
        sprockets.push(sprocket).uniq!
        server and server.remap
      end
    end
    
    # Creates a Machined sprocket with the given +name+ and +options+
    # and prepends it to the #sprockets list.
    def prepend_sprocket(name, options = {}, &block)
      create_sprocket(name, options, &block).tap do |sprocket|
        sprockets.unshift(sprocket).uniq!
        server and server.remap
      end
    end
    
    # Adds helpers that can be used within asset files.
    # There's two supported ways to add helpers, the first of
    # which is similar to how the `#helpers` DSL works in Sinatra:
    #
    #   helpers do
    #     def current_time
    #       Time.now
    #     end
    #   end
    #
    # The other way is to pass modules directly:
    #
    #   module CycleHelper
    #     def cycle(*args)
    #       # ...
    #     end
    #   end
    #
    #   helpers CycleHelper
    #
    def helpers(*modules, &block)
      @context_helpers << block if block_given?
      @context_helpers.push *modules
    end
    
    unless method_defined?(:define_singleton_method)
      # Add define_singleton_method for Ruby 1.8.7
      # This is used to define the sprocket accessor methods.
      def define_singleton_method(symbol, method = nil, &block) # :nodoc:
        singleton_class = class << self; self; end
        singleton_class.__send__ :define_method, symbol, method || block
      end
    end
    
    protected
    
    # Factory method for creating a `Machined::Sprocket` instance.
    # This is used in both `#append_sprocket` and `#prepend_sprocket`.
    def create_sprocket(name, options = {}, &block) # :nodoc:
      options.reverse_merge! :root => root
      Sprocket.new(self, options).tap do |sprocket|
        define_singleton_method(name) { sprocket }
        yield sprocket if block_given?
      end
    end
  end
end
