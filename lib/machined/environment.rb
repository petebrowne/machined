module Machined
  class Environment
    # An `Array` of the Sprockets environments (actually `Machined::Sprocket`
    # instances) that are the core of a Machined environment.
    attr_reader :sprockets
    
    # Creates a new Machined environment.
    def initialize
      @sprockets = []
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
      Sprocket.new(self, options).tap do |sprocket|
        define_singleton_method(name) { sprocket }
        yield sprocket if block_given?
      end
    end
  end
end
