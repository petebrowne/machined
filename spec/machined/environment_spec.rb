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
end
