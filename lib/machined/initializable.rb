require "active_support/concern"

module Machined
  # Initializable is a minimal version of
  # Rails::Initializable. Its implementation
  # of placing initializers before or after other
  # initializers is a bit naive, compared to the Rails
  # version, but it suits the needs of this lib.
  #
  # If they move Rails::Initializable into ActiveSupport
  # I'll remove this module and use theirs. Right now,
  # I don't want to `require "rails"` if I don't have to.
  module Initializable
    extend ActiveSupport::Concern
    
    class Initializer < Struct.new(:name, :block)
      # Run's the initializer's +block+ with the given
      # +context+ and yields the given +args+
      # to the block.
      def run(context, *args)
        context.instance_exec(*args, &block)
      end
    end
    
    module ClassMethods
      # Returns an array of the initializers for
      # this class.
      def initializers
        @initializers ||= []
      end
      
      # Creates a new initializer with the given name.
      # You can optionally pace initializers before or after
      # other initializers using the `:before` and `:after`
      # options. Otherwise the initializer is appended to the
      # of the list.
      def initializer(name, options = {}, &block)
        initializer = Initializer.new(name, block)
        
        if after = options[:after]
          initializers.insert initializer_index(after) + 1, initializer
        elsif before = options[:before]
          initializers.insert initializer_index(before), initializer
        else
          initializers << initializer
        end
      end
      
      protected
      
      # Returns the index of the initializer with
      # the given name.
      def initializer_index(name) # :nodoc:
        initializers.index do |initializer|
          initializer.name.to_sym == name.to_sym
        end or raise "The specified initializer, #{name.inspect}, does not exist"
      end
    end
    
    # Run each initializer with the given args
    # yielded to each initializer's block.
    def run_initializers(*args)
      return if @initializers_run
      self.class.initializers.each do |initializer|
        initializer.run self, *args
      end
      @initializers_run = true
    end
  end
end
