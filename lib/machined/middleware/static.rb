require 'rack'

module Machined
  module Middleware
    # Machined::Middleware::Static serves static files
    # from the given directory. If no static file is
    # found, the request gets passed on to the next
    # middleware or application. It's basically
    # a simplified version of ActionDispatch::Static.
    class Static
      def initialize(app, root = '.', cache_control = nil)
        @app           = app
        @root          = File.expand_path(root)
        @compiled_root = /^#{Regexp.escape(@root)}/
        @file_server   = ::Rack::File.new(@root, cache_control)
      end
      
      def call(env)
        case env['REQUEST_METHOD']
        when 'GET', 'HEAD'
          path = env['PATH_INFO'].chomp('/')
          if match = match?(path)
            env['PATH_INFO'] = match
            return @file_server.call(env)
          end
        end
        
        @app.call(env)
      end
      
      protected
      
      def match?(path)
        full_path = path.empty? ? @root : File.join(@root, path)
        matches   = Dir[full_path + '{,.html,/index.html}']
        match     = matches.detect { |f| File.file?(f) }
        
        if match
          ::Rack::Utils.escape match.sub(@compiled_root, '')
        else
          nil
        end
      end
    end
  end
end
