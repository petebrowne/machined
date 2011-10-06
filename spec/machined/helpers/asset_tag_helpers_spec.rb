require "spec_helper"

describe Machined::Helpers::AssetTagHelpers do
  include Machined::Helpers::AssetTagHelpers
  
  describe "#asset_path" do
    context "with URIs" do
      it "returns URIs untouched" do
        machined
        asset_path(:js, "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js").should ==
          "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
        asset_path(:js, "http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js").should ==
          "http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
        asset_path(:js, "//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js").should ==
          "//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
      end
    end
    
    context "with regular files" do
      it "returns absolute paths" do
        machined
        asset_path(:js, "/path/to/file.js").should == "/path/to/file.js"
        asset_path(:images, "/path/to/file.jpg").should == "/path/to/file.jpg"
      end
      
      it "appends the extension for javascripts and stylesheets" do
        machined
        asset_path(:js, "/path/to/file").should == "/path/to/file.js"
        asset_path(:css, "/path/to/file").should == "/path/to/file.css"
        asset_path(:images, "/path/to/file").should_not == "/path/to/file.jpg"
      end
      
      it "prepends a base URL if missing" do
        machined
        asset_path(:css, "main").should == "/stylesheets/main.css"
        asset_path(:js, "main").should == "/javascripts/main.js"
        asset_path(:images, "logo.jpg").should == "/images/logo.jpg"
      end
      
      it "appends a timestamp if the file exists in the output path" do
        within_construct do |c|
          file1 = c.file "public/javascripts/main.js"
          file2 = c.file "public/favicon.ico"
          
          mtime1 = Time.now - 600
          file1.utime mtime1, mtime1
          mtime2 = Time.now - 60
          file2.utime mtime2, mtime2
          
          machined
          asset_path(:js, "main").should == "/javascripts/main.js?#{mtime1.to_i}"
          asset_path(:images, "/favicon.ico").should == "/favicon.ico?#{mtime2.to_i}"
        end
      end
    end
    
    context "with assets" do
      it "prepends a base URL if missing" do
        within_construct do |c|
          c.file "assets/images/logo.jpg"
          c.file "assets/javascripts/main.js"
          c.file "assets/stylesheets/main.css"
          
          machined
          asset_path(:css, "main").should =~ %r(^/assets/main\.css)
          asset_path(:js, "main").should =~ %r(^/assets/main\.js)
          asset_path(:images, "logo.jpg").should =~ %r(^/assets/logo\.jpg)
        end
      end
      
      it "appends the timestamp of the asset's mtime" do
        within_construct do |c|
          c.file "assets/javascripts/main.js", "//= require dep"
          file = c.file "assets/javascripts/dep.js"
          
          mtime = Time.now + 600
          file.utime mtime, mtime
          
          asset_path(:js, "main").should == "/assets/main.js?#{mtime.to_i}"
        end
      end
    end
  end
end
