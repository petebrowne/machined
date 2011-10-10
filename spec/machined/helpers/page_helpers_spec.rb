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
        c.file "pages/index.html.erb", "---\nlayout: application\n---\n<%= layout %>"
        c.file "pages/about.html.erb", "---\nlayout: false\n---\n<%= layout %>"
        
        machined.pages["index.html"].to_s.should == "application"
        machined.pages["about.html"].to_s.should == "false"
      end
    end
  end
  
  describe "#context_for" do
    it "returns the context for the given path" do
      within_construct do |c|
        c.file "pages/index.html.erb", "<%= context_for('about').title %>"
        c.file "pages/about.html", "---\ntitle: Hello World\n---\n"
        
        machined.pages["index.html"].to_s.should == "Hello World"
      end
    end
    
    it "returns a self reference to avoid circular dependencies" do
      within_construct do |c|
        c.file "pages/index.html.erb", "<%= context_for('index') == self %>"
        
        machined.pages["index.html"].to_s.should == "true"
      end
    end
    
    it "adds the found context as a dependency" do
      within_construct do |c|
        c.file "pages/index.html.erb", "<%= context_for('about').title %>"
        dep = c.file "pages/about.html", "---\ntitle: Hello World\n---\n"
        
        asset = machined.pages["index.html"]
        asset.should be_fresh
        
        dep.open("w") { |f| f.write("---\ntitle: This Changed!\n---\n") }
        mtime = Time.now + 600
        dep.utime mtime, mtime
        
        asset.should be_stale
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
