require 'spec_helper'

describe Machined::CLI do
  describe '#compile' do
    it 'compiles the site' do
      machined.should_receive(:compile)
      Machined::Environment.should_receive(:new).with(:root => '.', :output_path => 'public', :environment => 'production', :config_path => 'machined.rb').and_return(machined)
      machined_cli 'compile -e production'
    end
  end
  
  describe '#new' do
    it 'creates a machined site directory' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.directory?('my_site').should be_true
      end
    end
    
    it 'creates source directories' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.directory?('my_site/pages').should be_true
        File.directory?('my_site/views').should be_true
        File.directory?('my_site/assets/images').should be_true
        File.directory?('my_site/assets/javascripts').should be_true
        File.directory?('my_site/assets/stylesheets').should be_true
      end
    end
    
    it 'creates an output path' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.directory?('my_site/public').should be_true
      end
    end
    
    it 'creates an default index page' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.read('my_site/pages/index.html.erb').should == <<-CONTENT.unindent
          ---
          title: Home Page
          ---
          <h1><%= title %></h1>
          <p>Find me in pages/index.html.erb</p>
        CONTENT
      end
    end
    
    it 'creates a default layout' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.read('my_site/views/layouts/application.html.erb').should == <<-CONTENT.unindent
          <!doctype html>
          <html>
            <head lang='en'>
              <meta charset='utf-8'>
              <title><%= title %></title>
              <%= stylesheet_link_tag 'application' %>
              <%= javascript_include_tag 'application' %>
            </head>
            <body>
              <%= yield %>
            </body>
          </html>
        CONTENT
      end
    end
    
    it 'creates a default javascript file' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.exist?('my_site/assets/javascripts/application.js.coffee').should be_true
      end
    end
    
    it 'creates a default stylesheet file' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.exist?('my_site/assets/stylesheets/application.css.scss').should be_true
      end
    end
    
    it 'creates a default Gemfile' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.read('my_site/Gemfile').should == <<-CONTENT.unindent
          source :rubygems
          
          gem 'machined', '#{Machined::VERSION}'
          
          gem 'sass', '~> 3.1'
          gem 'coffee-script', '~> 2.2'
          
          group :production do
            gem 'uglifier', '~> 1.0'
          end
        CONTENT
      end
    end
    
    it 'creates a default config file' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.read('my_site/machined.rb').should == <<-CONTENT.unindent
          require 'bundler'
          Bundler.require :default, config.environment.to_sym
          
          if config.environment == 'production'
            # Compress javascripts and stylesheets
            config.compress = true
            
            # Generate digests for assets URLs
            # config.digest_assets = true
            
            # Create gzipped versions of javascripts and stylesheets
            # config.gzip_assets = true
          end
          
          helpers do
            # Define helper methods here
          end
        CONTENT
      end
    end
    
    it 'creates a default rackup file' do
      within_construct do |c|
        machined_cli 'new my_site'
        File.read('my_site/config.ru').should == <<-CONTENT.unindent
          require 'machined'
          run Machined::Environment.new
        CONTENT
      end
    end
  end
  
  describe '#server' do
    it 'should start a Rack server' do
      app = machined
      Machined::Environment.should_receive(:new).with(:root => '.', :output_path => 'site', :environment => 'production', :config_path => 'machined.rb').and_return(app)
      Rack::Server.should_receive(:start).with(hash_including(:app => app, :environment => 'production', :Port => 5000))
      machined_cli 'server -o site -e production -p 5000'
    end
  end
  
  describe '#version' do
    it 'prints out the current version number' do
      output = machined_cli 'version'
      output.strip.should == Machined::VERSION
    end
  end
end
