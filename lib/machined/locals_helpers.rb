require "active_support/concern"
require "active_support/hash_with_indifferent_access"

module Machined
  module LocalsHelpers
    extend ActiveSupport::Concern
    
    # Adds psuedo local variables from the given hash, where
    # the key is the name of the variable. This is provided so
    # processors can add local variables without having access
    # to the next processor or template.
    def locals=(locals)
      if locals.nil?
        @locals = nil
      else
        self.locals.merge! locals
      end
    end
    
    # Returns the locals hash. It's actually an instance
    # of `ActiveSupport::HashWithIndifferentAccess`, so strings
    # and symbols can be used interchangeably.
    def locals
      @locals ||= ActiveSupport::HashWithIndifferentAccess.new
    end
    
    def method_missing(method, *args, &block) # :nodoc:
      if args.empty? && locals.key?(method)
        locals[method]
      else
        super
      end
    end
    
    def respond_to?(method) # :nodoc:
      super or locals.key?(method)
    end
  end
end
