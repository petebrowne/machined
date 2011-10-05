require "spec_helper"

describe Machined::Processors::LayoutProcessor do
  it "wraps the content with a layout" do
    within_construct do |c|
      c.file "pages/index.html", "<h1>Hello World</h1>"
      c.file "views/layouts/main.html.haml", "#layout= yield"
      
      machined.pages["index.html"].to_s.should == "<div id='layout'><h1>Hello World</h1></div>\n"
    end
  end
  
  it "uses the default layout set in the configuration" do
    within_construct do |c|
      c.file "pages/index.html", "<h1>Hello World</h1>"
      c.file "views/layouts/application.html.haml", "#layout= yield"
      
      machined :layout => "application"
      machined.pages["index.html"].to_s.should == "<div id='layout'><h1>Hello World</h1></div>\n"
    end
  end
  
  it "does not wrap the content with a layout when layout is false" do
    within_construct do |c|
      c.file "pages/index.html", "<h1>Hello World</h1>"
      c.file "views/layouts/application.html.haml", "#layout= yield"
      
      machined :layout => false
      machined.pages["index.html"].to_s.should == "<h1>Hello World</h1>"
    end
  end
end
