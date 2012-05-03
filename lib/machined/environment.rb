require 'ostruct'
require 'pathname'
require 'active_support/cache'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/module/delegation'
require 'active_support/string_inquirer'
require 'crush'
require 'tilt'

module Machined
  class Environment
    include Initializable
    
    # Delegate some common configuration accessors
    # to the config object.
    delegate :root, :config_path, :output_path, :lib_path, :environment,
             :to => :config
    
    # Default options for a Machined environment.
    DEFAULT_OPTIONS = {
      # Global configuration
      :root           => '.',
      :config_path    => 'machined.rb',
      :output_path    => 'public',
      :lib_path       => 'lib',
      :environment    => 'development',
      :cache          => nil,
      :skip_bundle    => false,
      :assets_only    => false,
      :digest_assets  => false,
      :gzip_assets    => false,
      :layout         => 'application',
      
      # Sprocket paths and URLs
      :assets_path    => 'assets',
      :assets_paths   => %w(app/assets lib/assets vendor/assets),
      :assets_url     => '/assets',
      :pages_path     => 'pages',
      :pages_paths    => %w(app/pages),
      :pages_url      => '/',
      :views_path     => 'views',
      :views_paths    => %w(app/views),
      
      # Compression configuration
      :compress       => false,
      :compress_css   => false,
      :compress_js    => false,
      :css_compressor => nil,
      :js_compressor  => nil
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
    
    # When the Machined environment is used as a Rack server, this
    # will reference the actual `Machined::Server` instance that handles
    # the requests.
    attr_reader :server
    
    # An `Array` of the Sprockets environments (actually `Machined::Sprocket`
    # instances) that are the core of a Machined environment.
    attr_reader :sprockets
    
    # When the Machined environment is compiling static files,
    # this will reference the `Machined::StaticCompiler` which handles
    # looping through the available files and generating them.
    attr_reader :static_compiler
    
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
      @config            = OpenStruct.new DEFAULT_OPTIONS.dup.merge(options)
      @sprockets         = []
      @context_helpers   = []
      config.root        = Pathname.new(config.root).expand_path
      config.config_path = root.join config.config_path
      config.output_path = root.join config.output_path
      config.lib_path    = root.join config.lib_path
      config.environment = ActiveSupport::StringInquirer.new(config.environment)
      
      run_initializers self
    end
    
    # If bundler is used, require all the gems in the Gemfile
    # for this environment.
    initializer :require_bundle do
      next if config.skip_bundle
      
      ENV['BUNDLE_GEMFILE'] ||= root.join('Gemfile').to_s
      if File.exist? ENV['BUNDLE_GEMFILE']
        require 'bundler/setup'
        require 'sprockets'
        Bundler.require :default, config.environment.to_sym
      end
    end
    
    # Appends the lib directory to the load path.
    # Changes to files in this directory will trigger a reload
    # of the Machined environment.
    initializer :setup_autoloading do
      next unless lib_path.exist?
      
      require 'active_support/dependencies'
      ActiveSupport::Dependencies.autoload_paths << lib_path.to_s
    end
    
    # Create and append the default `assets` sprocket.
    # This sprocket mimics the asset pipeline in Rails 3.1.
    initializer :create_assets_sprocket do
      append_sprocket :assets, :assets => true
    end
    
    # Create and append the default `pages` sprocket.
    # This sprocket is responsible for processing HTML pages,
    # and includes processors for wrapping pages in layouts and
    # reading YAML front matter.
    initializer :create_pages_sprocket do
      next if config.assets_only
      
      append_sprocket :pages do |pages|
        pages.register_mime_type     'text/html', '.html'
        pages.register_preprocessor  'text/html', Processors::FrontMatterProcessor
        pages.register_postprocessor 'text/html', Processors::LayoutProcessor
      end
    end
    
    # Create and append the default `views` sprocket.
    # The files in this sprocket are not compiled. They are
    # meant to be resources for the other sprockets. For instance,
    # the layouts for the `pages` sprocket will be located here.
    initializer :create_views_sprocket do
      append_sprocket :views, :compile => false do |views|
        views.register_mime_type 'text/html', '.html'
      end
    end
    
    # If there's a config file, execute with the scope of the
    # newly created Machined environment. The default sprockets are
    # available at this point, but not fully configured. This is so
    # you can actually configure the sprockets with this file.
    initializer :eval_config_file do
      instance_eval config_path.read if config_path.exist?
      
      # This could be changed in the config file
      config.output_path = root.join config.output_path
      remove_sprocket(:pages) if config.assets_only && @pages
    end
    
    # Register all available Tilt templates to every
    # sprocket other than the assets sprocket
    initializer :register_all_templates do
      sprockets.each do |sprocket|
        sprocket.use_all_templates unless sprocket.config.assets
      end
    end
    
    # Setup the global cache. Defaults to an in memory
    # caching for development, and a file based cache for production.
    initializer :configure_cache do
      if config.cache.nil?
        if config.environment == 'production'
          config.cache = :file_store, 'tmp/cache'
        else
          config.cache = :memory_store
        end
      end
      
      config.cache = ActiveSupport::Cache.lookup_store(*config.cache)
    end
    
    # Do any configuration to the assets sprockets necessary
    # after the config file has been evaled.
    initializer :configure_assets_sprocket do
      next unless @assets
      
      # Append the directories within the configured paths
      append_paths assets, Utils.existent_directories(root.join(config.assets_path))
      config.assets_paths.each do |asset_path|
        append_paths assets, Utils.existent_directories(root.join(asset_path))
      end
      
      # Append paths from Sprockets-plugin
      assets.append_plugin_paths if assets.respond_to?(:append_plugin_paths)
      
      # Search for Rails Engines with assets and append those
      if defined? Rails::Engine
        Rails::Engine.subclasses.each do |engine|
          append_paths assets, engine.paths['app/assets'].existent_directories
          append_paths assets, engine.paths['lib/assets'].existent_directories
          append_paths assets, engine.paths['vendor/assets'].existent_directories
        end
      end
      
      # Setup the base URL for the assets (like the Rails asset_prefix)
      assets.config.url = config.assets_url
      
      # Use the global cache store
      assets.cache = config.cache
    end
    
    # Do any configuration to the pages sprockets necessary
    # after the config file has been evaled.
    initializer :configure_pages_sprocket do
      next unless @pages
      
      # Append the configured pages paths
      append_path  pages, config.pages_path
      append_paths pages, config.pages_paths
      
      # Setup the base URL for the pages
      pages.config.url = config.pages_url
      
      # Use the global cache store
      pages.cache = config.cache
    end
    
    # Do any configuration to the views sprockets necessary
    # after the config file has been evaled.
    initializer :configure_views_sprocket do
      next unless @views
      
      # Append the configured views paths
      append_path  views, config.views_path
      append_paths views, config.views_paths
      
      # Use the global cache store
      views.cache = config.cache
    end
    
    # Setup the JavaScript and CSS compressors
    # for the assets based on the configuration.
    initializer :configure_assets_compression do
      next unless @assets
      
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
    
    # Finally, configure Sprockets::Helpers to
    # match curernt configuration.
    initializer :configure_sprockets_helpers do
      next unless @assets
      
      Sprockets::Helpers.configure do |helpers|
        helpers.environment = assets
        helpers.digest      = config.digest_assets
        helpers.prefix      = config.assets_url
        helpers.public_path = config.output_path.to_s
      end
    end
    
    # Handles Rack requests by passing the +env+ to an instance
    # of `Machined::Server`.
    def call(env)
      @server ||= Server.new self
      server.call(env)
    end
    
    # Loops through the available static files and generates them in
    # the output path.
    def compile
      @static_compiler ||= StaticCompiler.new self
      static_compiler.compile
    end
    
    # Reloads the environment. This will re-evaluate the config file.
    def reload
      config.cache.clear if config.cache.respond_to?(:clear)
      initialize config.marshal_dump
    end
    
    # Creates a Machined sprocket with the given +name+ and +options+
    # and appends it to the #sprockets list. This will also create
    # an accessor with the given name that references the created sprocket.
    #
    #   machined.append_sprocket :updates, :url => '/news' do |updates|
    #     updates.append_path 'updates'
    #   end
    #   
    #   machined.updates            # => #<Machined::Sprocket...>
    #   machined.updates.config.url # => '/news'
    #   machined.updates.paths      # => [ '.../updates' ]
    #
    def append_sprocket(name, options = {}, &block)
      create_sprocket(name, options, &block).tap do |sprocket|
        sprockets.push(sprocket).uniq!
      end
    end
    
    # Creates a Machined sprocket with the given +name+ and +options+
    # and prepends it to the #sprockets list.
    def prepend_sprocket(name, options = {}, &block)
      create_sprocket(name, options, &block).tap do |sprocket|
        sprockets.unshift(sprocket).uniq!
      end
    end
    
    # Removes the sprocket with the given name. This is useful if
    # you don't need one of the default Sprockets.
    def remove_sprocket(name)
      if sprocket = get_sprocket(name)
        sprockets.delete sprocket
        set_sprocket(name, nil)
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
    
    # Returns the sprocket registered with the given name.
    def get_sprocket(name)
      instance_variable_get "@#{name}"
    end
    
    # Sets the sprocket with the give name.
    def set_sprocket(name, sprocket)
      instance_variable_set "@#{name}", sprocket
    end
    
    # Factory method for creating a `Machined::Sprocket` instance.
    # This is used in both `#append_sprocket` and `#prepend_sprocket`.
    def create_sprocket(name, options = {}, &block) # :nodoc:
      options.reverse_merge! :root => root
      Sprocket.new(self, options).tap do |sprocket|
        define_singleton_method(name) { get_sprocket(name) }
        set_sprocket(name, sprocket)
        yield sprocket if block_given?
      end
    end
    
    # Appends the given +path+ to the given +sprocket+
    # This makes sure the path is relative to the `root` path
    # or an absolute path pointing somewhere else. It also
    # checks if it exists before appending it.
    def append_path(sprocket, path) # :nodoc:
      path = Pathname.new(path).expand_path(root)
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
        Tilt['js']
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
        Tilt['css']
      end
    end
  end
end
