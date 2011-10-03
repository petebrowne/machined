require "spec_helper"

describe Machined::Precompiler do
  it "generates all of the static files" do
    within_construct do |c|
      c.file "assets/javascripts/main.js",       "//= require _dep"
      c.file "assets/javascripts/_dep.js",       "var app = {};"
      c.file "assets/stylesheets/main.css.scss", %(@import "dep";\nbody { color: $color; })
      c.file "assets/stylesheets/_dep.scss",     "$color: red;"
      c.file "assets/images/logo.jpg"
      c.file "pages/index.html.md.erb", <<-CONTENT.unindent
        ---
        title: Hello World
        ---
        # <%= title %>
        
        Here's some *content*.
      CONTENT
      c.file "views/layouts/main.html.haml", <<-CONTENT.unindent
        !!! 5
        %html
          %head
            %title= title
          %body
            = yield
      CONTENT
    
      puts machined.precompile.inspect
      
      c.join("public/assets/main.js").read.should == "var app = {};\n"
      c.join("public/assets/main.css").read.should == "body {\n  color: red; }\n"
      c.join("public/assets/logo.jpg").exist?.should be_true
      c.join("public/index.html").read.should == <<-CONTENT.unindent
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
end
