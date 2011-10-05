require "ostruct"
require "pathname"
require "active_support/core_ext/hash/reverse_merge"
require "crush"
require "tilt"

module Machined
  class Environment
    # Default options for a Machined environment.
    DEFAULT_OPTIONS = {
      :root         => ".",
      :config_path  => "machined.rb",
      :output_path  => "public",
      :assets_path  => "assets",
      :assets_paths => %w(lib/assets vendor/assets),
      :assets_url   => "/assets",
      :pages_path   => "pages",
      :pages_url    => "/",
      :views_path   => "views",
      :environment  => "development",
      :layout       => "main"
    }.freeze
    
    # A hash of Javascript compressors. When `config.js_compressor`
    # is set using a symbol, such as `:uglifier`, this is where
    # we check which engine to use.
    JS_COMPRESSORS = {
      :jsmin    => Crush::JSMin,
      :packr    => Crush::Packr,
      :yui      => Crush::YUI::JavaScriptCompressor,
      :closure  => Crush::Closure::Compiler,
      :uglifier => Crush::Uglifier
    }
    
    # A hash of CSS compressors. When `config.css_compressor`
    # is set using a symbol, such as `:sass`, this is where
    # we check which engine to use.
    CSS_COMPRESSORS = {
      :cssmin    => Crush::CSSMin,
      :rainpress => Crush::Rainpress,
      :yui       => Crush::YUI::CssCompressor,
      :sass      => Crush::Sass::Engine
    }
    
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
      append_sprocket :assets, :assets => true
      
      # Create and append the default `pages` sprocket.
      # This sprocket is responsible for processing HTML pages,
      # and includes processors for wrapping pages in layouts and
      # reading YAML front matter.
      append_sprocket :pages do |pages|
        pages.register_mime_type     "text/html", ".html"
        pages.register_preprocessor  "text/html", Processors::FrontMatterProcessor
        pages.register_postprocessor "text/html", Processors::LayoutProcessor
      end
      
      # Create and append the default `views` sprocket.
      # The files in this sprocket are not compiled. They are
      # meant to be resources for the other sprockets. For instance,
      # the layouts for the `pages` sprocket will be located here.
      append_sprocket :views, :compile => false do |views|
        views.register_mime_type "text/html", ".html"
      end
      
      # If there's a config file, execute with the scope of the
      # newly created Machined environment. The default sprockets are
      # available at this point, but not fully configured. This is so
      # you can actually configure the sprockets with this file.
      config_file = root.join(config.config_path)
      instance_eval config_file.read if config_file.exist?
      
      # Append the paths for each sprocket. The default `assets` sprocket
      # is special, because we actually append the directories within
      # the given paths (like the Rails 3.1 asset pipeline).
      append_path  pages, config.pages_path
      append_paths pages, config.pages_paths
      append_path  views, config.views_path
      append_paths views, config.views_paths
      append_paths assets, Utils.existent_directories(root.join(config.assets_path))
      config.assets_paths.each do |asset_path|
        append_paths assets, Utils.existent_directories(root.join(asset_path))
      end
      
      # Set the URLs for the compilable default sprockets.
      assets.config[:url] = config.assets_url
      pages.config[:url]  = config.pages_url
      
      # Now setup assets compression.
      if config.compress
        config.compress_js  = true
        config.compress_css = true
      else
        config.compress_js  = true if config.js_compressor
        config.compress_css = true if config.css_compressor
      end
      assets.js_compressor  = js_compressor  if config.compress_js
      assets.css_compressor = css_compressor if config.compress_css
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
    
    # Appends the given +path+ to the given +sprocket+
    # This makes sure the path is relative to the `root` path
    # or an absolute path pointing somewhere else. It also
    # checks if it exists before appending it.
    def append_path(sprocket, path) # :nodoc:
      path = root.join(path)
      sprocket.append_path(path) if path.exist?
    end
    
    # Appends the given `Array` of +paths+ to the given +sprocket+.
    def append_paths(sprocket, paths) # :nodoc:
      paths or return
      paths.each do |path|
        append_path sprocket, path
      end
    end
    
    # Returns the Javascript compression engine, based on
    # what's set in `config.js_compressor`. If `config.js_compressor`
    # is nil, let Tilt + Crush decide which one to use.
    def js_compressor # :nodoc:
      case config.js_compressor
      when Crush::Engine
        config.js_compressor
      when Symbol, String
        JS_COMPRESSORS[config.js_compressor.to_sym]
      else
        Crush.register_js
        Tilt["js"]
      end
    end
    
    # Returns the CSS compression engine, based on
    # what's set in `config.css_compressor`. If `config.css_compressor`
    # is nil, let Tilt + Crush decide which one to use.
    def css_compressor # :nodoc:
      case config.css_compressor
      when Crush::Engine
        config.css_compressor
      when Symbol, String
        CSS_COMPRESSORS[config.css_compressor.to_sym]
      else
        Crush.register_css
        Tilt["css"]
      end
    end
  end
end
