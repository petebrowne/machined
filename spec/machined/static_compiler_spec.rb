require "spec_helper"

describe Machined::StaticCompiler do
  it "generates all of the static files" do
    within_construct do |c|
      c.file "assets/javascripts/application.js",       "//= require _dep"
      c.file "assets/javascripts/_dep.js",              "var app = {};"
      c.file "assets/stylesheets/application.css.scss", %(@import "dep";\nbody { color: $color; })
      c.file "assets/stylesheets/_dep.scss",            "$color: red;"
      c.file "assets/images/logo.jpg"
      c.file "pages/index.html.md.erb", <<-CONTENT.unindent
        ---
        title: Hello World
        ---
        # <%= title %>
        
        Here's some *content*.
      CONTENT
      c.file "views/layouts/application.html.haml", <<-CONTENT.unindent
        !!! 5
        %html
          %head
            %title= title
          %body
            = yield
      CONTENT
    
      machined.compile
      
      File.read("public/assets/application.js").should == "var app = {};\n"
      File.read("public/assets/application.css").should == "body {\n  color: red; }\n"
      File.exist?("public/assets/logo.jpg").should be_true
      File.read("public/index.html").should == <<-CONTENT.unindent
        <!DOCTYPE html>
        <html>
          <head>
            <title>Hello World</title>
          </head>
          <body>
            <h1>Hello World</h1>
            
            <p>Here's some <em>content</em>.</p>
          </body>
        </html>
      CONTENT
    end
  end
  
  it "generates digests when configured" do
    within_construct do |c|
      c.file "_/js/application.js", "var app = {};"
      c.file "_/css/application.css", "body { color: red; }"
      c.file "_/img/logo.jpg"
      c.file "pages/index.html"
      
      machined(:digest_assets => true, :assets_url => "/_", :assets_path => "_").compile
      
      asset = machined.assets["application.js"]
      File.read("public/_/application-#{asset.digest}.js").should == "var app = {};\n"
      asset = machined.assets["application.css"]
      File.read("public/_/application-#{asset.digest}.css").should == "body { color: red; }\n"
      asset = machined.assets["logo.jpg"]
      File.exist?("public/_/logo-#{asset.digest}.jpg").should be_true
      asset = machined.pages["index.html"]
      File.exist?("public/index-#{asset.digest}.html").should be_false
      File.exist?("public/index.html").should be_true
    end
  end
  
  it "generates gzipped files when configured" do
    within_construct do |c|
      c.file "assets/javascripts/application.js"
      c.file "assets/stylesheets/application.css"
      c.file "assets/images/logo.jpg"
      c.file "pages/index.html"
      
      machined(:gzip_assets => true).compile
      
      File.exist?("public/assets/application.js.gz").should be_true
      File.exist?("public/assets/application.css.gz").should be_true
      File.exist?("public/assets/logo.jpg.gz").should_not be_true
      File.exist?("public/index.html.gz").should_not be_true
    end
  end
end
