require "spec_helper"

describe Machined::Context do
  describe "#machined" do
    it "returns a reference to the Machined environment" do
      with_context do |context, output|
        context.machined.should be(machined)
      end
    end
  end
  
  describe "#config" do
    it "returns a reference to the Machined environment's configuration" do
      with_context do |context, output|
        machined.config.layout = "application"
        context.config.layout.should == "application"
      end
    end
  end
end
