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
  end
end
