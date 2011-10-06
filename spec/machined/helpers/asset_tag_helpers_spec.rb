require "spec_helper"

describe Machined::Helpers::AssetTagHelpers do
  def asset_path(kind, source)
    Machined::Helpers::AssetTagHelpers::AssetPath.new(machined, source, kind).to_s
  end
  
  describe "#asset_path" do
    it "returns URIs untouched" do
      asset_path(:js, "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js").should ==
        "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
      asset_path(:js, "http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js").should ==
        "http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
      asset_path(:js, "//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js").should ==
        "//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
    end
    
    it "returns absolute paths" do
      asset_path(:js, "/path/to/file.js").should =~ %r(^/path/to/file\.js)
      asset_path(:images, "/path/to/file.jpg").should =~ %r(^/path/to/file\.jpg)
    end
    
    it "appends the extension for javascripts and stylesheets" do
      asset_path(:js, "/path/to/file").should =~ %r(^/path/to/file\.js)
      asset_path(:css, "/path/to/file").should =~ %r(^/path/to/file\.css)
      asset_path(:images, "/path/to/file").should_not =~ %r(^/path/to/file\.jpg)
    end
    
    it "appends a timestamp if the file exists in the output path" do
      within_construct do |c|
        file  = c.file "public/favicon.ico"
        mtime = file.mtime
        asset_path(:images, "/favicon.ico").should == "/favicon.ico?#{mtime.to_i}"
        asset_path(:images, "/favicon.gif").should == "/favicon.gif"
      end
    end
  end
end
