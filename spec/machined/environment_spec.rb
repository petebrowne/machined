require 'spec_helper'

describe Machined::Environment do
  describe '#initialize' do
    it 'loads configuration from a config file' do
      within_construct do |c|
        c.file 'machined.rb', <<-CONTENT.unindent
          config.output_path = 'site'
          append_sprocket :updates
        CONTENT
        machined.config.output_path.should == Pathname.new('site').expand_path
        machined.updates.should be_a(Machined::Sprocket)
      end
    end
  end

  describe '#append_sprocket' do
    it 'creates a new Sprockets environment' do
      sprocket = machined.append_sprocket :updates
      sprocket.should be_a(Sprockets::Environment)
    end

    it 'appends the sprocket to #sprockets' do
      sprocket = machined.append_sprocket :updates
      machined.sprockets.last.should be(sprocket)
    end

    it 'adds a method with the given name which returns the sprocket' do
      sprocket = machined.append_sprocket :updates
      machined.updates.should be(sprocket)
      Machined::Environment.method_defined?(:updates).should be_false
    end

    it 'yields the sprocket for configuration' do
      yielded_sprocket = nil
      sprocket = machined.append_sprocket :updates do |updates|
        yielded_sprocket = updates
      end
      yielded_sprocket.should be(sprocket)
    end

    it 'initializes the sprocket with a reference to the Machined environment' do
      sprocket = machined.append_sprocket :updates
      sprocket.machined.should be(machined)
    end

    it 'initializes the sprocket with configuration' do
      sprocket = machined.append_sprocket :updates, :root => 'spec/machined'
      sprocket.root.should == File.expand_path('spec/machined')
    end
  end

  describe '#prepend_sprocket' do
    it 'creates a new Sprockets environment' do
      sprocket = machined.prepend_sprocket :updates
      sprocket.should be_a(Sprockets::Environment)
    end

    it 'prepends the sprocket to #sprockets' do
      sprocket = machined.prepend_sprocket :updates
      machined.sprockets.first.should be(sprocket)
    end
  end

  describe '#remove_sprocket' do
    it 'sets the accessor method to return nil' do
      machined.remove_sprocket :pages
      machined.pages.should be_nil
    end

    it 'removes the sprockets from the sprockets list' do
      views = machined.views
      machined.remove_sprocket :views
      machined.sprockets.should_not include(views)
    end
  end

  describe '#helpers' do
    it 'adds methods defined in the given block to the Context' do
      machined.helpers do
        def hello
          'world'
        end
      end

      build_context.hello.should == 'world'
    end

    it 'adds methods defined in the given module to the Context' do
      helper = Module.new do
        def hello
          'world'
        end
      end
      machined.helpers helper
      build_context.hello.should == 'world'
    end
  end

  describe '#reload' do
    it 'knows when helpers are changed' do
      within_construct do |c|
        c.file 'machined.rb', 'helpers do; def hello; "hello"; end; end'
        build_context.hello.should == 'hello'

        modify 'machined.rb', 'helpers do; def hello; "world"; end; end'
        machined.reload
        build_context.hello.should == 'world'
      end
    end

    it 'knows when configuration is changed' do
      within_construct do |c|
        c.file 'machined.rb'
        machined.output_path.should == c.join('public')

        modify 'machined.rb', 'config.output_path = "output"'
        machined.reload
        machined.output_path.should == c.join('output')
      end
    end

    it 'does not re-append sprockets' do
      within_construct do |c|
        c.file 'machined.rb'
        machined.sprockets.length.should == 3

        modify 'machined.rb', 'config.output_path = "output"'
        machined.reload
        machined.sprockets.length.should == 3
      end
    end

    it 're-evaluates assets when configuration changes' do
      within_construct do |c|
        c.file 'machined.rb', 'helpers do; def hello; "hello"; end; end'
        c.file 'pages/index.html.erb', '<%= hello %>'
        machined.pages['index.html'].to_s.should == 'hello'

        modify 'machined.rb', 'helpers do; def hello; "world"; end; end'
        machined.reload
        machined.pages['index.html'].to_s.should == 'world'
      end
    end

    it 'knows when a lib file changes' do
      within_construct do |c|
        c.file 'lib/hello.rb', 'module Hello; def hello; "hello"; end; end'
        c.file 'machined.rb', 'helpers Hello'
        machined :skip_autoloading => false
        build_context.hello.should == 'hello'

        modify 'lib/hello.rb', 'module Hello; def hello; "world"; end; end'
        machined.reload
        build_context.hello.should == 'world'
      end
    end
  end

  describe '#environment' do
    it 'is wrapped in String inquirer' do
      machined :environment => 'development'
      machined.environment.development?.should be_true
      machined.environment.production?.should be_false
      machined.environment.test?.should be_false

      machined :environment => 'production', :reload => true
      machined.environment.development?.should be_false
      machined.environment.production?.should be_true
      machined.environment.test?.should be_false
    end
  end

  describe 'default assets sprocket' do
    it 'appends the standard asset paths' do
      within_construct do |c|
        c.directory 'assets/images'
        c.directory 'assets/javascripts'
        c.directory 'assets/stylesheets'
        c.directory 'vendor/assets/images'
        c.directory 'vendor/assets/javascripts'
        c.directory 'vendor/assets/stylesheets'

        machined.assets.paths.sort.should match_paths(%w(
          assets/images
          assets/javascripts
          assets/stylesheets
          vendor/assets/images
          vendor/assets/javascripts
          vendor/assets/stylesheets
        )).with_root(c)
      end
    end

    it 'appends the available asset paths' do
      within_construct do |c|
        c.directory 'assets/css'
        c.directory 'assets/img'
        c.directory 'assets/js'
        c.directory 'assets/plugins'

        machined.assets.paths.sort.should match_paths(%w(
          assets/css
          assets/img
          assets/js
          assets/plugins
        )).with_root(c)
      end
    end

    # it 'appends Rails::Engine paths' do
    #   require 'rails'
    #   require 'jquery-rails'
    #   machined.assets.paths.first.should =~ %r(/jquery-rails-[\d\.]+/vendor/assets/javascripts)
    #   Rails::Engine.subclasses.delete Jquery::Rails::Engine
    # end

    it 'appends Sprockets::Plugin paths' do
      require 'sprockets-plugin'

      within_construct do |c|
        plugin_dir = c.directory 'plugin/assets'
        plugin_dir.directory 'images'
        plugin_dir.directory 'javascripts'
        plugin_dir.directory 'stylesheets'

        plugin = Class.new(Sprockets::Plugin)
        plugin.append_paths_in plugin_dir

        machined.assets.paths.sort.should match_paths(%w(
          plugin/assets/images
          plugin/assets/javascripts
          plugin/assets/stylesheets
        )).with_root(c)
        Sprockets::Plugin.plugins.delete plugin
      end
    end

    it 'compiles web assets' do
      within_construct do |c|
        c.file 'assets/javascripts/main.js', '//= require dep'
        c.file 'assets/javascripts/dep.js', 'var app = {};'
        c.file 'assets/stylesheets/main.css.scss', "@import 'dep';\nbody { color: $color; }"
        c.file 'assets/stylesheets/_dep.scss', '$color: red;'

        machined.assets['main.js'].to_s.should == "var app = {};\n"
        machined.assets['main.css'].to_s.should == "body {\n  color: red; }\n"
      end
    end
  end

  describe 'default pages sprocket' do
    after { Sprockets.clear_paths }

    it 'appends the pages path' do
      within_construct do |c|
        c.directory 'pages'
        machined.pages.paths.should match_paths(%w(pages)).with_root(c)
      end
    end

    it 'compiles html pages' do
      within_construct do |c|
        c.file 'pages/index.html.haml', '%h1 Hello World'
        machined.pages['index.html'].to_s.should == "<h1>Hello World</h1>\n"
      end
    end

    it 'does not compile other assets from additiontal paths' do
      within_construct do |c|
        vendor_path = c.directory 'vendor-assets'
        vendor_path.file 'main.js', '//= require dep'
        vendor_path.file 'dep.js', 'var app = {};'
        vendor_path.file 'main.css.scss', "@import 'dep';\nbody { color: $color; }"
        vendor_path.file '_dep.scss', '$color: red;'
        Sprockets.append_path vendor_path

        machined.pages['main.js'].to_s.should_not == "var app = {};\n"
        machined.pages['main.css'].to_s.should_not == "body {\n  color: red; }\n"
      end
    end

    context 'when :assets_only is set in constructor' do
      it 'is never created' do
        machined :assets_only => true
        machined.respond_to?(:pages).should be_false
        machined.sprockets.should == [ machined.assets, machined.views ]
      end
    end

    context 'when :assets_only is set in the config file' do
      it 'is removed' do
        within_construct do |c|
          c.file 'machined.rb', 'config.assets_only = true'

          machined
          machined.pages.should be_nil
          machined.sprockets.should == [ machined.assets, machined.views ]
        end
      end
    end
  end

  describe 'default views sprocket' do
    it 'appends the views path' do
      within_construct do |c|
        c.directory 'views'
        machined.views.paths.should match_paths(%w(views)).with_root(c)
      end
    end

    it 'compiles html pages' do
      within_construct do |c|
        c.file 'views/layouts/main.html.haml', '%h1 Hello World'
        machined.views['layouts/main.html'].to_s.should == "<h1>Hello World</h1>\n"
      end
    end
  end

  describe 'compression' do
    context 'with compress set to true' do
      it 'compresses javascripts and stylesheets' do
        within_construct do |c|
          c.file 'assets/javascripts/main.js',       '//= require dep'
          c.file 'assets/javascripts/dep.js',        'var app = {};'
          c.file 'assets/stylesheets/main.css.scss', "@import 'dep';\nbody { color: $color; }"
          c.file 'assets/stylesheets/_dep.scss',     '$color: red;'

          Crush::Uglifier.should_receive(:compress).with("var app = {};\n").and_return('compressed')
          Crush::Sass::Engine.should_receive(:compress).with("body {\n  color: red; }\n").and_return('compressed')

          machined :compress => true
          machined.assets['main.js'].to_s.should == 'compressed'
          machined.assets['main.css'].to_s.should == 'compressed'
        end
      end
    end

    context 'with a js_compressor set' do
      it 'compresses using that compressor' do
        within_construct do |c|
          c.file 'assets/javascripts/main.js', 'var app = {};'
          c.file 'machined.rb', 'config.js_compressor = :packr'
          Crush::Packr.should_receive(:compress).with("var app = {};\n").and_return('compressed')
          machined.assets['main.js'].to_s.should == 'compressed'
        end
      end
    end
  end

  it 'autoloads files from the lib directory' do
    within_construct do |c|
      c.file 'lib/hello.rb', 'module Hello; def hello; "hello"; end; end'
      c.file 'machined.rb', 'helpers Hello'
      machined :skip_autoloading => false
      build_context.hello.should == 'hello'
    end
  end
end
