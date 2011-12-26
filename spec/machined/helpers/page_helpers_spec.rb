require "spec_helper"

describe Machined::Helpers::PageHelpers do
  describe "#layout" do
    it "defaults to the default layout" do
      within_construct do |c|
        c.file "pages/index.html.erb", "<%= layout %>"
        
        machined :layout => "application"
        machined.pages["index.html"].to_s.should == "application"
      end
    end
    
    it "returns the layout set in the front matter" do
      within_construct do |c|
        c.file "pages/index.html.erb", "---\nlayout: main\n---\n<%= layout %>"
        c.file "pages/about.html.erb", "---\nlayout: false\n---\n<%= layout %>"
        
        machined.pages["index.html"].to_s.should == "main"
        machined.pages["about.html"].to_s.should == "false"
      end
    end
  end
  
  describe "#title" do
    it "returns a titleized version of the filename" do
      within_construct do |c|
        c.file "pages/about-us.html.erb", "<%= title %>"
        c.file "pages/about/our-team.html.erb", "<%= title %>"
        
        machined.pages["about-us"].to_s.should == "About Us"
        machined.pages["about/our-team"].to_s.should == "Our Team"
      end
    end
    
    it "returns the local set in the front matter" do
      within_construct do |c|
        c.file "pages/index.html.erb", "---\ntitle: Homepage\n---\n<%= title %>"
        
        machined.pages["index"].to_s.should == "Homepage"
      end
    end
  end
  
  describe "#url" do
    it "returns the URL for the current page or asset" do
      within_construct do |c|
        c.file "assets/javascripts/main.js.erb", "<%= url %>"
        c.file "assets/stylesheets/main.css.erb", "<%= url %>"
        c.file "pages/index.html.erb", "<%= url %>"
        c.file "pages/about.html.erb", "<%= url %>"
        c.file "pages/about/team.html.erb", "<%= url %>"
        
        machined.assets["main.js"].to_s.should == "/assets/main.js;\n"
        machined.assets["main.css"].to_s.should == "/assets/main.css"
        machined.pages["index.html"].to_s.should == "/"
        machined.pages["about.html"].to_s.should == "/about"
        machined.pages["about/team.html"].to_s.should == "/about/team"
      end
    end
  end
end
