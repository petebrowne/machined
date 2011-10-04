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
  
  describe "#render" do
    it "renders partials" do
      within_construct do |c|
        c.file "pages/index.html.erb", <<-CONTENT.unindent
          <%= render "partial1" %>
          <%= render "partial2" %>
          <%= render "partials/partial3" %>
        CONTENT
        c.file "views/partial1.md", "# Hello World"
        c.file "views/_partial2.haml", "%p Here's some Content..."
        c.file "views/partials/_partial3.html", "<p>And some more</p>\n"
        
        # puts machined.views.paths.inspect
        machined.pages["index.html"].to_s.should == <<-CONTENT.unindent
          <h1>Hello World</h1>
          <p>Here's some Content...</p>
          <p>And some more</p>
        CONTENT
      end
    end
    
    it "renders partials with locals" do
      within_construct do |c|
        c.file "pages/index.html.erb", %(<%= render "partial", :text => "Hello World" %>)
        c.file "views/partial.haml", "%h1= text"
        
        machined.pages["index.html"].to_s.should == "<h1>Hello World</h1>\n"
      end
    end
    
    it "renders partial collections" do
      within_construct do |c|
        c.file "pages/index.html.erb", %(<%= render "number", :collection => [1,2,3] %>)
        c.file "views/number.haml", "= number\n= number_counter"
        
        machined.pages["index.html"].to_s.should == "1\n1\n2\n2\n3\n3\n"
      end
    end
  end
end
