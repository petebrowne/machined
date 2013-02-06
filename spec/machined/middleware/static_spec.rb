require 'spec_helper'

describe Machined::Middleware::Static do
  include Rack::Test::Methods

  let(:root)    { create_construct }
  after(:each)  { root.destroy! }

  let(:app) do
    Rack::Builder.new.tap do |app|
      app.use Machined::Middleware::Static, root, 'Cache-control' => 'public, max-age=60'
      app.run Proc.new { |env| [200, {'Content-Type' => 'text/plain'}, ['Hello, World!']] }
    end.to_app
  end

  it 'serves dynamic content' do
    get('/nofile').body.should == 'Hello, World!'
  end

  it 'sets cache control headers' do
    root.file 'file.txt', 'File Content'
    get('/file.txt').headers['Cache-Control'].should == 'public, max-age=60'
  end

  it 'serves static files in the root directory' do
    root.file 'file.txt', 'File Content'
    get('/file.txt').body.should == 'File Content'
  end

  it 'serves static files in a subdirectory' do
    root.file 'sub/directory/file.txt', 'Subdirectory File Content'
    get('/sub/directory/file.txt').body.should == 'Subdirectory File Content'
  end

  it 'serves static index file in the root directory' do
    root.file 'index.html', 'Static Index Content'
    get('/index.html').body.should == 'Static Index Content'
    get('/index').body.should      == 'Static Index Content'
    get('/').body.should           == 'Static Index Content'
    get('').body.should            == 'Static Index Content'
  end

  it 'serves static index file in directory' do
    root.file 'foo/index.html', 'Static Index Content in Directory'
    get('/foo/index.html').body.should == 'Static Index Content in Directory'
    get('/foo/').body.should           == 'Static Index Content in Directory'
    get('/foo').body.should            == 'Static Index Content in Directory'
  end

  it 'serves static html file in directory' do
    root.file 'foo/bar.html', 'HTML Content in Directory'
    get('/foo/bar.html').body.should == 'HTML Content in Directory'
    get('/foo/bar/').body.should     == 'HTML Content in Directory'
    get('/foo/bar').body.should      == 'HTML Content in Directory'
  end
end
