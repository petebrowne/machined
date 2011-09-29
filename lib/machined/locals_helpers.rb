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
    
    # Returns true if the given +name+ has been set as a local
    # variable.
    def has_local?(name)
      locals.key? name
    end
    
    # Returns the default layout, unless overridden by
    # the YAML front matter.
    def layout
      if has_local?(:layout)
        locals[:layout]
      else
        machined.config[:layout]
      end
    end
    
    def method_missing(method, *args, &block) # :nodoc:
      if args.empty? && has_local?(method)
        locals[method]
      else
        super
      end
    end
    
    def respond_to?(method) # :nodoc:
      super or has_local?(method)
    end
  end
end
