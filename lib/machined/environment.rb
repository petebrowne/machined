require "pathname"
require "active_support/core_ext/hash/reverse_merge"

module Machined
  class Environment
    # 
    DEFAULT_OPTIONS = {
      :root        => ".",
      :asset_paths => %w(vendor/assets lib/assets app/assets),
      :pages_path  => "app/pages",
      :views_path  => "app/views"
    }.freeze
    
    # The global configuration for the Machined
    # environment.
    attr_reader :config
    
    # A reference to the root directory the Machined
    # environment is run from.
    attr_reader :root
    
    # An `Array` of the Sprockets environments (actually `Machined::Sprocket`
    # instances) that are the core of a Machined environment.
    attr_reader :sprockets
    
    # Creates a new Machined environment. Sets up a default assets sprocket
    # similar to what you would use in a Rails 3.1 app.
    def initialize(options = {})
      @config    = DEFAULT_OPTIONS.dup.merge options
      @root      = Pathname.new(config[:root]).expand_path
      @sprockets = []
      
      append_sprocket :assets do |assets|
        config[:asset_paths].each do |asset_path|
          Utils.existent_directories(Utils.join(root, asset_path)).each do |path|
            assets.append_path path
          end
        end
      end
      
      append_sprocket :pages do |pages|
        pages_path = Utils.join(root, config[:pages_path])
        pages.append_path(pages_path) if pages_path.exist?
      end
      
      append_sprocket :views do |views|
        views_path = Utils.join(root, config[:views_path])
        views.append_path(views_path) if views_path.exist?
      end
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
      end
    end
    
    # Creates a Machined sprocket with the given +name+ and +options+
    # and prepends it to the #sprockets list.
    def prepend_sprocket(name, options = {}, &block)
      create_sprocket(name, options, &block).tap do |sprocket|
        sprockets.unshift(sprocket).uniq!
      end
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
    
    def create_sprocket(name, options = {}, &block)
      options.reverse_merge! :root => root
      Sprocket.new(self, options).tap do |sprocket|
        define_singleton_method(name) { sprocket }
        yield sprocket if block_given?
      end
    end
  end
end
