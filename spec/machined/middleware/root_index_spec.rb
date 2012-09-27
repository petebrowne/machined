require 'spec_helper'

describe Machined::Middleware::RootIndex do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new.tap do |app|
      app.use Machined::Middleware::RootIndex
      app.run Proc.new { |env| [200, {'Content-Type' => 'text/plain'}, [env['PATH_INFO']]] }
    end.to_app
  end

  it 'adds index.html to the root index' do
    get('/').body.should == '/index.html'
  end

  it 'does not change the path info for normal files' do
    get('/about').body.should == '/about'
    get('/about.html').body.should == '/about.html'
    get('/about/').body.should == '/about/'
    get('/assets/main.css').body.should == '/assets/main.css'
  end
end
