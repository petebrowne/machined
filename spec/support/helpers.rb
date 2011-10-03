module Machined
  module SpecHelpers
    # Convenience method for creating a new Machined environment
    def machined(config = {})
      @machined ||= Machined::Environment.new(config)
    end
    
    # Convenience method for creating a new Machined sprocket,
    # with an automatic reference to the current Machined
    # environment instance.
    def create_sprocket(config = {})
      Machined::Sprocket.new machined, config
    end
  
    # Yields a real context instance, created from
    # a file with the given +content+. The processed
    # output from the file is the second yielded param.
    def with_context(content = "")
      within_construct do |c|
        # Create the necessary files
        c.file "context/machined.css.erb", content
        
        # Create a sprocket that points to the correct dir
        sprocket = create_sprocket
        sprocket.append_path "context"
        
        # Find the asset and yield the context and output
        asset = sprocket["machined.css"]
        yield asset.send(:blank_context), asset.to_s
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
