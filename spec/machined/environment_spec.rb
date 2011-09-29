require "spec_helper"

describe Machined::Environment do
  let(:machined) { Machined::Environment.new }
  
  describe "#append_sprocket" do
    it "creates a new Sprockets environment" do
      sprocket = machined.append_sprocket :updates
      sprocket.should be_a(Sprockets::Environment)
    end
    
    it "appends the sprocket to #sprockets" do
      sprocket = machined.append_sprocket :updates
      machined.sprockets.last.should be(sprocket)
    end
    
    it "adds a method with the given name which returns the sprocket" do
      sprocket = machined.append_sprocket :updates
      machined.updates.should be(sprocket)
      Machined::Environment.method_defined?(:updates).should be_false
    end
    
    it "yields the sprocket for configuration" do
      yielded_sprocket = nil
      sprocket = machined.append_sprocket :updates do |updates|
        yielded_sprocket = updates
      end
      yielded_sprocket.should be(sprocket)
    end
    
    it "initializes the sprocket with a reference to the Machined environment" do
      sprocket = machined.append_sprocket :updates
      sprocket.machined.should be(machined)
    end
    
    it "initializes the sprocket with configuration" do
      sprocket = machined.append_sprocket :updates, :root => "spec/machined"
      sprocket.config[:root].should == "spec/machined"
    end
  end
  
  describe "#prepend_sprocket" do
    it "creates a new Sprockets environment" do
      sprocket = machined.prepend_sprocket :updates
      sprocket.should be_a(Sprockets::Environment)
    end
    
    it "prepends the sprocket to #sprockets" do
      sprocket = machined.prepend_sprocket :updates
      machined.sprockets.first.should be(sprocket)
    end
  end
  
  describe "#assets" do
    it "appends the standard asset paths" do
      within_construct do |c|
        c.directory "app/assets/images"
        c.directory "app/assets/javascripts"
        c.directory "app/assets/stylesheets"
        c.directory "vendor/assets/images"
        c.directory "vendor/assets/javascripts"
        c.directory "vendor/assets/stylesheets"
        
        machined.assets.paths.should == [
          "vendor/assets/images",
          "vendor/assets/javascripts",
          "vendor/assets/stylesheets",
          "app/assets/images",
          "app/assets/javascripts",
          "app/assets/stylesheets"
        ].map { |path| c.join(path).to_s }
      end
    end
    
    it "appends the available asset paths" do
      within_construct do |c|
        c.directory "app/assets/css"
        c.directory "app/assets/img"
        c.directory "app/assets/js"
        c.directory "app/assets/plugins"
        
        machined.assets.paths.should == [
          "app/assets/css",
          "app/assets/img",
          "app/assets/js",
          "app/assets/plugins"
        ].map { |path| c.join(path).to_s }
      end
    end
    
    it "compiles web assets" do
      within_construct do |c|
        c.file "app/assets/javascripts/main.js",       "//= require dep"
        c.file "app/assets/javascripts/dep.js",        "var app = {};"
        c.file "app/assets/stylesheets/main.css.scss", "@import 'dep';\nbody { color: $color; }"
        c.file "app/assets/stylesheets/_dep.scss",     "$color: red;"
        
        machined.assets["main.js"].to_s.should == "var app = {};\n"
        machined.assets["main.css"].to_s.should == "body {\n  color: red; }\n"
      end
    end
  end
  
  describe "#pages" do
    it "appends the pages path" do
      within_construct do |c|
        c.directory "app/pages"
        
        machined.pages.paths.should == [
          "app/pages"
        ].map { |path| c.join(path).to_s }
      end
    end
    
    it "compiles html pages" do
      within_construct do |c|
        c.file "app/pages/index.html.haml", "%h1 Hello World"
        
        machined.pages["index.html"].to_s.should == "<h1>Hello World</h1>\n"
      end
    end
  end
  
  describe "#views" do
    it "appends the views path" do
      within_construct do |c|
        c.directory "app/views"
        
        machined.views.paths.should == [
          "app/views"
        ].map { |path| c.join(path).to_s }
      end
    end
    
    it "compiles html pages" do
      within_construct do |c|
        c.file "app/views/layouts/main.html.haml", "%h1 Hello World"
        
        machined.views["layouts/main.html"].to_s.should == "<h1>Hello World</h1>\n"
      end
    end
  end
end
