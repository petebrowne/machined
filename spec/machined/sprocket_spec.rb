require "spec_helper"

describe Machined::Sprocket do
  let(:machined) { Machined::Environment.new }
  
  describe "#initialize" do
    it "keeps a reference to the Machined environment" do
      sprocket = Machined::Sprocket.new machined
      sprocket.machined.should be(machined)
    end
    
    it "sets the root path" do
      sprocket = Machined::Sprocket.new machined
      sprocket.root.should == Pathname.new(".").expand_path.to_s
      sprocket = Machined::Sprocket.new machined, :root => "spec/machined"
      sprocket.root.should == Pathname.new("spec/machined").expand_path.to_s
    end
  end
end
