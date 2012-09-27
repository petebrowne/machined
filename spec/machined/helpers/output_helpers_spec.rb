require 'spec_helper'

describe Machined::Helpers::OutputHelpers do
  describe '#current_engine' do
    it 'returns :haml within a Haml template' do
      within_construct do |c|
        c.file 'pages/index.html.haml', '= current_engine.inspect'
        machined.pages['index'].to_s.should == ":haml\n"
      end
    end

    it 'returns :erb within an ERB template' do
      within_construct do |c|
        c.file 'pages/index.html.erb', '<%= current_engine.inspect %>'
        machined.pages['index'].to_s.should == ':erb'
      end
    end

    it 'returns :erubis within an Erubis template' do
      within_construct do |c|
        c.file 'pages/index.html.erubis', '<%= current_engine.inspect %>'
        machined.pages['index'].to_s.should == ':erubis'
      end
    end

    it 'returns :slim within a Slim template' do
      within_construct do |c|
        c.file 'pages/index.html.slim', '= current_engine.inspect'
        machined.pages['index'].to_s.should == ':slim'
      end
    end
  end

  describe '#capture and #concat' do
    it 'captures blocks in haml' do
      within_construct do |c|
        c.file 'pages/index.html.haml', <<-CONTENT.unindent
          - content_tag :h1 do
            Hello World
        CONTENT

        machined.pages['index'].to_s.strip.should == "<h1>Hello World\n</h1>"
      end
    end

    it 'captures blocks in erb' do
      within_construct do |c|
        c.file 'pages/index.html.erb', <<-CONTENT.unindent
          <% content_tag :h1 do %>
            Hello World
          <% end %>
        CONTENT

        machined.pages['index'].to_s.strip.should == "<h1>  Hello World\n</h1>"
      end
    end

    it 'captures blocks in erubis' do
      within_construct do |c|
        c.file 'pages/index.html.erubis', <<-CONTENT.unindent
          <% content_tag :h1 do %>
            Hello World
          <% end %>
        CONTENT

        machined.pages['index'].to_s.strip.should == "<h1>  Hello World\n</h1>"
      end
    end

    it 'captures blocks in slim' do
      within_construct do |c|
        c.file 'pages/index.html.slim', <<-CONTENT.unindent
          - content_tag :h1 do
            | Hello World
        CONTENT

        machined.pages['index'].to_s.strip.should == '<h1>Hello World</h1>'
      end
    end
  end
end
