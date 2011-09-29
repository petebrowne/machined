require "tilt"

module Machined
  class LayoutProcessor < Tilt::Template
    # A reference to the Sprockets context
    attr_reader :context
    
    def prepare
    end
    
    def evaluate(context, locals, &block)
      @context = context
      if layout? && pathname = resolve_layout
        context.depend_on pathname
        template = Tilt.new pathname.to_s
        template.render(context) { data }
      else
        data
      end
    end
    
    protected
    
    def layout?
      context.layout != false
    end
    
    def resolve_layout
      context.machined.views.resolve("layouts/#{context.layout}", :content_type => context.content_type)
    rescue Sprockets::FileNotFound, Sprockets::ContentTypeMismatch
      nil
    end
  end
end
  