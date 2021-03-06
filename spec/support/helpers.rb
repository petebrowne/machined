require 'pathname'
require 'active_support/core_ext/hash/reverse_merge'

module Machined
  module SpecHelpers
    # Convenience method for creating a new Machined environment
    def machined(config = {})
      @machined = nil if config.delete(:reload)
      @machined ||= Machined::Environment.new(config.reverse_merge(:skip_bundle => true, :skip_autoloading => true))
    end

    # Convenience method for creating a new Machined sprocket,
    # with an automatic reference to the current Machined
    # environment instance.
    def create_sprocket(config = {})
      Machined::Sprocket.new machined, config
    end

    # Returns a fresh context, that can be used to test helpers.
    def build_context(logical_path = 'application.js', options = {})
      pathname = options[:pathname] || Pathname.new('assets').join(logical_path).expand_path
      env      = options[:env] || machined.assets

      env.context_class.new env, logical_path, pathname
    end

    # Runs the CLI with the given args.
    def machined_cli(args, silence = true)
      capture(:stdout) {
        Machined::CLI.start args.split(' ')
      }
    end

    # Modifies the given file
    def modify(file, content = nil)
      Pathname.new(file).tap do |file|
        file.open('w') { |f| f.write(content) } if content
        future = Time.now + 60
        file.utime future, future
      end
    end

    # Captures the given stream and returns it:
    #
    #   stream = capture(:stdout) { puts 'Cool' }
    #   stream # => "Cool\n"
    #
    def capture(stream)
      begin
        stream = stream.to_s
        eval "$#{stream} = StringIO.new"
        yield
        result = eval("$#{stream}").string
      ensure
        eval "$#{stream} = #{stream.upcase}"
      end

      result
    end
  end
end
