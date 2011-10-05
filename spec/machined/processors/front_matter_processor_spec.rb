require "spec_helper"

describe Machined::Processors::FrontMatterProcessor do
  it "parses the front matter and adds locals" do
    within_construct do |c|
      c.file "pages/index.html.haml", <<-CONTENT.unindent
        ---
        title: Hello
        tags:
        - 1
        - 2
        ---
        = title.inspect
        = tags.inspect
      CONTENT
      
      machined.pages["index.html"].to_s.should == <<-CONTENT.unindent
        "Hello"
        [1, 2]
      CONTENT
    end
  end
  
  it "ignores pages without front matter" do
    within_construct do |c|
      c.file "pages/index.html.md", <<-CONTENT.unindent
        Title
        ---
        Another Title
        ---
        Content...
      CONTENT
      machined.pages["index.html"].to_s.should == <<-CONTENT.unindent
        <h2>Title</h2>
        
        <h2>Another Title</h2>
        
        <p>Content...</p>
      CONTENT
    end
  end
end
