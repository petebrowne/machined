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
        machined.config[:layout] = "application"
        context.config[:layout].should == "application"
      end
    end
  end
  
  describe "#locals=" do
    it "sets psuedo local variables" do
      with_context do |context, output|
        context.locals = { :title => "Hello World", :body => nil }
        context.title.should == "Hello World"
        context.respond_to?(:title).should be_true
        context.body.should be_nil
        context.respond_to?(:body).should be_true
        expect { context.not_a_local }.to raise_error(NoMethodError)
        context.respond_to?(:not_a_local).should be_false
      end
    end
  end
end
