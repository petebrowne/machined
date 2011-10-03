require "thor"

module Machined
  class CLI < Thor
    include Thor::Actions
    
    default_task :help
    source_root  File.expand_path("../templates", __FILE__)
    
    desc "compile", "Compiles the site from the source files"
    def compile
      machined.compile
    end
    map %w(c build b) => :compile
    
    desc "new SITE_NAME", "Generates a new site with the give name"
    def new(site_name)
      directory "site", site_name
    end
    map %w(n generate g) => :new
    
    desc "server", "Runs a local Rack based web server"
    def server
      # ...
    end
    map %w(s rackup r) => :server
    
    desc "version", "Prints out the version"
    def version
      puts VERSION
    end
    map %w(v -v --version) => :version
    
    protected
    
    def machined
      @machined ||= Environment.new
    end
  end
end
