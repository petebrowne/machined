require "spec_helper"

describe Machined::StaticCompiler do
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
    
      machined.compile
      
      File.read("public/assets/main.js").should == "var app = {};\n"
      File.read("public/assets/main.css").should == "body {\n  color: red; }\n"
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
end
