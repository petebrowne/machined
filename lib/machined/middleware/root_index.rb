require 'rack'

module Machined
  module Middleware
    # Sprockets >= 2.4.4 no longer infers that '/' should equal '/index.html',
    # so this middleware changes the PATH_INFO if necessary.
    class RootIndex
      def initialize(app)
        @app = app
      end

      def call(env)
        env['PATH_INFO'] = '/index.html' if env['PATH_INFO'] == '/'
        @app.call(env)
      end
    end
  end
end
