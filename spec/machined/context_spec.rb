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
