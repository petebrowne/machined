require "pathname"
require "active_support/core_ext/hash/reverse_merge"

module Machined
  module SpecHelpers
    # Convenience method for creating a new Machined environment
    def machined(config = {})
      @machined ||= Machined::Environment.new(config.reverse_merge(:skip_bundle => true))
    end
    
    # Convenience method for creating a new Machined sprocket,
    # with an automatic reference to the current Machined
    # environment instance.
    def create_sprocket(config = {})
      Machined::Sprocket.new machined, config
    end
  
    # Returns a fresh context, that can be used to test helpers.
    def context(logical_path = "application.js", options = {})
      @context ||= begin
        pathname = options[:pathname] || Pathname.new(File.join("assets", logical_path)).expand_path
        env      = options[:env] || machined.assets
        
        env.context_class.new env, logical_path, pathname
      end
    end
    
    # Runs the CLI with the given args.
    def machined_cli(args, silence = true)
      capture(:stdout) {
        Machined::CLI.start args.split(" ")
      }
    end
    
    # Captures the given stream and returns it:
    #
    #   stream = capture(:stdout) { puts "Cool" }
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
