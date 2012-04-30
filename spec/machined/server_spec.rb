require 'spec_helper'

describe Machined::Server do
  include Rack::Test::Methods
  
  let(:app) do
    Rack::Builder.new.tap do |app|
      app.use Rack::ShowExceptions
      app.run machined
    end.to_app
  end
  
  it 'serves up assets at the asset url' do
    within_construct do |c|
      c.file 'assets/javascripts/main.js', "var app = {};\n"
      c.file 'assets/stylesheets/main.css', "body { color: red; }\n"
      
      get '/assets/main.js'
      last_response.body.should == "var app = {};\n"
      last_response.content_type.should == 'application/javascript'
      
      get '/assets/main.css'
      last_response.body.should == "body { color: red; }\n"
      last_response.content_type.should == 'text/css'
    end
  end
  
  it 'serves up pages as the base url' do
    within_construct do |c|
      c.file 'pages/index.html', "<h1>Hello World</h1>\n"
      c.file 'pages/about.html', "<h1>About Us</h1>\n"
      
      get '/'
      last_response.body.should == "<h1>Hello World</h1>\n"
      last_response.content_type.should == 'text/html'
      
      get '/about'
      last_response.body.should == "<h1>About Us</h1>\n"
      last_response.content_type.should == 'text/html'
    end
  end
  
  it 'does not serve up views' do
    within_construct do |c|
      c.file 'views/about.html', "<h1>About Us</h1>\n"
      
      get '/about'
      last_response.should be_not_found
      
      get '/views/about'
      last_response.should be_not_found
    end
  end
  
  it 'serves up custom sprockets' do
    within_construct do |c|
      dir = c.directory 'updates'
      dir.file 'new-site.html', "<h1>Hello World</h1>\n"
      
      machined.append_sprocket :updates, :url => '/updates' do |updates|
        updates.append_path dir
        updates.register_mime_type 'text/html', '.html'
      end
      
      get '/updates/new-site'
      last_response.body.should == "<h1>Hello World</h1>\n"
      last_response.content_type.should == 'text/html'
    end
  end
  
  it 'serves up files in the output path' do
    within_construct do |c|
      c.file 'public/index.html', "<h1>Hello World</h1>\n"
      
      get '/index.html'
      last_response.body.should == "<h1>Hello World</h1>\n"
      last_response.content_type.should == 'text/html'
    end
  end
  
  it 'does not raise Sprockets::CircularDependency error after an error' do
    within_construct do |c|
      c.file 'pages/index.html.haml', "%p Hello\n  World"
      
      get '/'
      last_response.should_not be_ok
      
      c.file 'pages/index.html.erb', "<h1>Hello World</h1>\n"
      
      get '/'
      last_response.should be_ok
      last_response.body.should == "<h1>Hello World</h1>\n"
    end
  end
end
