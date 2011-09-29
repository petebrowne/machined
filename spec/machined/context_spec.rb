require "spec_helper"

describe Machined::Context do
  let(:machined) { Machined::Environment.new }
  let(:sprocket) { Machined::Sprocket.new(machined) }
  
  # Yields a real context instance, created from
  # a file with the given +content+. The processed
  # output from the file is the second yielded param.
  def with_context(content = "")
    within_construct do |construct|
      construct.file "context/machined.css.erb", content
      sprocket.append_path "context"
      asset = sprocket["machined.css"]
      yield asset.send(:blank_context), asset.to_s
    end
  end
  
  describe "#machined" do
    it "returns a reference to the Machined environment" do
      with_context do |context, output|
        context.machined.should be(machined)
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
