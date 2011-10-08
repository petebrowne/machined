require "spec_helper"

describe Machined::Helpers::RenderHelpers do
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
    
    it "returns the original locals state once rendered" do
      within_construct do |c|
        c.file "pages/index.html.erb", <<-CONTENT.unindent
          ---
          title: Hello World
          ---
          <%= render "partial", :title => "Title...", :text => "Text..." %>
          title: <%= title %>
          text: <%= respond_to?(:text) %>
        CONTENT
        c.file "views/partial.html.erb", "title: <%= title %>\ntext: <%= text %>\n"
        
        machined.pages["index.html"].to_s.should == <<-CONTENT.unindent
          title: Title...
          text: Text...
          title: Hello World
          text: false
        CONTENT
      end
    end
    
    it "renders partial collections" do
      within_construct do |c|
        c.file "pages/index.html.erb", %(<%= render "number", :collection => [1,2,3] %>)
        c.file "views/number.haml", "= number\n= number_counter"
        
        machined.pages["index.html"].to_s.should == "1\n1\n2\n2\n3\n3\n"
      end
    end
    
    it "does not wrap the partial in a layout" do
      within_construct do |c|
        c.file "pages/index.html.erb", %(<%= render "partial" %>)
        c.file "views/layouts/main.html.erb", "<h1><%= yield %></h1>"
        c.file "views/partial.html.erb", "Hello World"
        
        machined.pages["index.html"].to_s.should == "<h1>Hello World</h1>"
      end
    end
    
    it "optionally wraps the partial in a layout" do
      within_construct do |c|
        c.file "pages/index.html.erb", %(<%= render "partial", :layout => "partial" %>)
        c.file "views/layouts/partial.html.erb", "<h1><%= yield %></h1>"
        c.file "views/partial.html.erb", "Hello World"
        
        machined.pages["index.html"].to_s.should == "<h1>Hello World</h1>"
      end
    end
    
    it "raises a Sprockets::FileNotFound error if the partial is missing" do
      within_construct do |c|
        c.file "pages/index.html.erb", %(<%= render "partial" %>)
        
        expect {
          machined.pages["index.html"].to_s
        }.to raise_error(Sprockets::FileNotFound)
      end
    end
  end
end
