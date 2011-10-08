require "pathname"
require "active_support/concern"

module Machined
  module Helpers
    module RenderHelpers
      extend  ActiveSupport::Concern
      include LocalsHelpers
      
      # This is the short form of both #render_partial and #render_collection.
      # It works exactly like #render_partial, except if you pass the
      # +:collection+ option:
      #
      #   <%= render "ad", :collection => advertisements %>
      #   # is the same as:
      #   <%= render_collection advertisements, "ad" %>
      # 
      def render(partial, options = {})
        if collection = options.delete(:collection)
          render_collection collection, partial, options
        else
          render_partial partial, options
        end
      end
      
      # Renders the given +collection+ of objects with the given
      # +partial+ template. This follows the same conventions
      # of Rails' partial rendering, where the individual objects
      # will be set as local variables based on the name of the partial:
      #
      #   <%= render_collection advertisements, "ad" %>
      #
      # This will render the "ad" template and pass the local variable
      # +ad+ to the template for display. An iteration counter will automatically
      # be made available to the template with a name of the form
      # +partial_name_counter+. In the case of the example above, the
      # template would be fed +ad_counter+.
      def render_collection(collection, partial, options = {})
        return if collection.nil? || collection.empty?
        
        template = resolve_partial(partial)
        counter  = 0
        collection.inject('') do |output, object|
          counter += 1
          output << render_partial(template, options.merge(:object => object, :counter => counter))
        end
      end
      
      # Renders a single +partial+. The primary options are:
      #
      #   * <tt>:locals</tt> - A hash of local variables to use when
      #                        rendering the partial.
      #   * <tt>:object</tt> - The object rendered in the partial.
      #   * <tt>:as</tt>     - The name of the object to use.
      #
      # == Some Examples
      #
      #   <%= render_partial "account" %>
      #
      # This will look for a template in the views paths with the name
      # "account" or "_account". The files can be any processable Tilt
      # template files, like ".erb", ".md", or ".haml" - or just plain ".html".
      #
      #   <%= render_partial "account", :locals => { :account => buyer } %>
      #
      # This will set `buyer` as a local variable named "account". This can
      # actually be written a few different ways:
      #
      #   <%= render_partial "account", :account => buyer %>
      #   # Leftover options are assumed to be locals.
      #   <%= render_partial "account", :object => buyer %>
      #   # The local variable name "account" is inferred.
      #
      # As mentioned above, any options that are not used by #render_partial
      # are assumed to be locals when the +:locals+ option is not set.
      #
      # Also mentioned above, the +:object+ option works like in Rails,
      # where the local variable name will be inferred from the partial name.
      # This can be overridden with the +:as+ option:
      #
      #   <%= render_partial "account", :object => buyer, :as => "user" %>
      #
      # This is equivalent to:
      #
      #   <%= render_partial "account", :locals => { :user => buyer } %>
      #
      def render_partial(partial, options = {})
        template = resolve_partial(partial)
        depend_on template
        
        partial_locals = {}
        
        # Temporarily use a different layout (default to no layout)
        partial_locals[:layout] = options.delete(:layout) || false
        
        # Add object with the name of the partial
        # as the local variable name.
        if object = options.delete(:object)
          object_name = options.delete(:as) || template.to_s[/_?(\w+)(\.\w+)*$/, 1]
          partial_locals[object_name] = object
          partial_locals["#{object_name}_counter"] = options.delete(:counter)
        end
        
        # Add locals from leftover options
        if leftover_locals = options.delete(:locals) || options
          partial_locals.merge!(leftover_locals)
        end
        
        # Now evaluate the partial
        with_locals(partial_locals) { return evaluate(template) }
      end
      
      protected
      
      # Attempts to find a view with the given path,
      # while also looking for a version with a partial-style
      # name (prefixed with an "_").
      def resolve_partial(path) # :nodoc:
        path = Pathname.new(path)
        path.absolute? and return path
        
        # First look for the normal path
        machined.views.resolve(path) { |found| return found }
        
        # Then look for the partial-style version
        unless path.basename.to_s =~ /^_/
          partial = path.dirname.join("_#{path.basename}")
          machined.views.resolve(partial) { |found| return found }
        end
        
        raise Sprockets::FileNotFound, "couldn't find file '#{path}'"
      end
    end
  end
end
