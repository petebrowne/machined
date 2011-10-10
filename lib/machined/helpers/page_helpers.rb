require "active_support/concern"
require "active_support/core_ext/string/inflections"

module Machined
  module Helpers
    module PageHelpers
      extend  ActiveSupport::Concern
      include LocalsHelpers
    
      # Returns the context of the given path. This is useful
      # if you want to get the information from the front matter
      # of a specific page.
      def context_for(path, environment = self.environment)
        pathname = environment.resolve path, :base_path => self.pathname.dirname
        
        contexts_cache[pathname] ||= begin
          if pathname == self.pathname
            self
          else
            depend_on_asset pathname
            environment.find_asset(pathname).send :dependency_context
          end
        end
      end
      
      # Returns the default layout, unless overridden by
      # the YAML front matter.
      def layout
        if has_local? :layout
          locals[:layout]
        else
          machined.config.layout
        end
      end
      
      # Returns the local variable, title, if set. Otherwise
      # return a titleized version of the filename.
      def title
        if has_local? :title
          locals[:title]
        else
          File.basename(logical_path).titleize
        end
      end
    
      # Returns the URL to this asset, appending the sprocket's URL.
      # For HTML files, this will return pretty URLs.
      def url
        File.join(environment.config.url, @logical_path).sub /(index)?\.html$/, ''
      end
      
      protected
      
      # Returns a hash where we store found contexts.
      def contexts_cache # :nodoc:
        @contexts_cache ||= {}
      end
    end
  end
end
