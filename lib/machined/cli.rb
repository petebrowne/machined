require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/slice'
require 'shellwords'
require 'thor'

module Machined
  class CLI < Thor
    include Thor::Actions

    SAVED_OPTIONS_FILE = '.machined'

    default_task :help
    source_root  File.expand_path('../templates', __FILE__)

    class_option 'root', :aliases => '-r',
      :desc => 'Path to the root directory of the project',
      :default => '.'
    class_option 'config_path', :aliases => '-c',
      :desc => 'Path to the config file',
      :default => 'machined.rb'
    class_option 'output_path', :aliases => '-o',
      :desc => 'Path to the output directory of the project',
      :default => 'public'
    class_option 'environment', :aliases => '-e',
      :desc => 'Sets the environment',
      :default => 'development'

    desc 'compile', 'Compiles the site from the source files'
    def compile
      machined.compile
    end
    map %w(c build b) => :compile

    desc 'new SITE_NAME', 'Generates a new site with the give name'
    def new(site_name)
      directory 'site', site_name
    end
    map %w(n generate g) => :new

    desc 'server', 'Runs a local Rack based web server'
    method_option :port, :aliases => '-p',
      :desc => 'Serve at the given port',
      :type => :numeric, :default => 3000
    method_option :host, :aliases => '-h',
      :desc => 'Listen on the given given host',
      :default => '0.0.0.0'
    method_option :server, :aliases => '-s',
      :desc => 'Serve with the given handler'
    method_option :daemonize, :aliases => '-D',
      :desc => 'Run daemonized in the background',
      :type => :boolean
    method_option :pid, :aliases => '-P',
      :desc => 'File to store PID'
    def server
      require 'rack'
      Rack::Server.start rack_options
    end
    map %w(s rackup r) => :server

    desc 'version', 'Prints out the version'
    def version
      say VERSION
    end
    map %w(v -v --version) => :version

    protected

    def machined
      @machined ||= Environment.new machined_options
    end

    # Returns the current environment, using the 'RACK_ENV' variable
    # if set.
    def environment # :nodoc
      ENV['RACK_ENV'] || options['environment']
    end

    # Returns the options needed for setting up
    # Machined environment.
    def machined_options # :nodoc:
      symbolized_options(:root, :config_path, :output_path).tap do |machined_options|
        machined_options[:environment] = environment
      end
    end

    # Returns the options needed for setting up the Rack server.
    def rack_options # :nodoc:
      symbolized_options(:port, :host, :server, :daemonize, :pid).tap do |rack_options|
        rack_options[:environment] = environment
        rack_options[:Port] = rack_options.delete :port
        rack_options[:Host] = rack_options.delete :host
        rack_options[:app] = machined
      end
    end

    # Returns a mutable options hash with symbolized keys.
    # Optionally, returns only the keys given.
    def symbolized_options(*keys) # :nodoc:
      @symbolized_options ||= begin
        opts = {}.merge(options)
        opts.merge! saved_options if saved_options?
        opts.symbolize_keys
      end
      @symbolized_options.slice(*keys)
    end

    # Returns the parsed saved options.
    def saved_options
      parse_options File.read(SAVED_OPTIONS_FILE)
    end

    # Returns true if there's a saved options file in the project
    def saved_options?
      File.exist? SAVED_OPTIONS_FILE
    end

    # Use Thor::Options to parse the given options String (or Array).
    def parse_options(options)
      options = Shellwords.split(options) unless options.is_a?(Array)
      parser = Thor::Options.new(self.class.class_options)
      parser.parse(options)
    end
  end
end
