require 'spec_helper'

describe Machined::Helpers::AssetTagHelpers do
  let(:context) { build_context }
  
  describe '#asset_path' do
    context 'with URIs' do
      it 'returns URIs untouched' do
        context.asset_path(:js, 'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js').should ==
          'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js'
        context.asset_path(:js, 'http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js').should ==
          'http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js'
        context.asset_path(:js, '//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js').should ==
          '//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js'
      end
    end
    
    context 'with regular files' do
      it 'returns absolute paths' do
        context.asset_path(:js, '/path/to/file.js').should == '/path/to/file.js'
        context.asset_path(:images, '/path/to/file.jpg').should == '/path/to/file.jpg'
      end
      
      it 'appends the extension for javascripts and stylesheets' do
        context.asset_path(:js, '/path/to/file').should == '/path/to/file.js'
        context.asset_path(:css, '/path/to/file').should == '/path/to/file.css'
        context.asset_path(:images, '/path/to/file').should_not == '/path/to/file.jpg'
      end
      
      it 'prepends a base URL if missing' do
        context.asset_path(:css, 'main').should == '/stylesheets/main.css'
        context.asset_path(:js, 'main').should == '/javascripts/main.js'
        context.asset_path(:images, 'logo.jpg').should == '/images/logo.jpg'
      end
      
      it 'appends a timestamp if the file exists in the output path' do
        within_construct do |c|
          c.file 'public/javascripts/main.js'
          c.file 'public/favicon.ico'
          
          context.asset_path(:js, 'main').should =~ %r(/javascripts/main.js\?\d+)
          context.asset_path(:images, '/favicon.ico').should =~ %r(/favicon.ico\?\d+)
        end
      end
    end
    
    context 'with assets' do
      it 'prepends a base URL if missing' do
        within_construct do |c|
          c.file 'assets/images/logo.jpg'
          c.file 'assets/javascripts/main.js'
          c.file 'assets/stylesheets/main.css'
          
          context.asset_path(:css, 'main').should == '/assets/main.css'
          context.asset_path(:js, 'main').should == '/assets/main.js'
          context.asset_path(:images, 'logo.jpg').should == '/assets/logo.jpg'
        end
      end
      
      it 'uses the digest path if configured' do
        within_construct do |c|
          c.file 'assets/javascrtips/main.js'
          
          machined :digest_assets => true
          context.asset_path(:js, 'main').should =~ %r(/assets/main-[0-9a-f]+.js)
        end
      end
    end
  end
  
  describe '#asset_path' do
    it 'is compatible with the Sprockets::Helpers API' do
      within_construct do |c|
        c.file 'assets/images/logo.jpg'
        
        context.image_path('logo.jpg', :digest => true).should =~ %r(/assets/logo-[0-9a-f]+.jpg)
      end
    end
  end
end
