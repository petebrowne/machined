require 'spec_helper'

describe Machined::Watcher do
  let(:watcher) do
    # Mimic usage in Machined
    Machined::Watcher.new [machined.config_path] + Dir[machined.lib_path.join('**/*.rb')]
  end
  
  it 'knows when the config file changes' do
    within_construct do |c|
      c.file 'machined.rb'
      watcher.perform.should be_false
      
      modify 'machined.rb'
      watcher.perform.should be_true
      watcher.perform.should be_false
    end
  end
  
  it 'knows when a lib file changes' do
    within_construct do |c|
      c.file 'lib/file.rb'
      watcher.perform.should be_false
      
      modify 'lib/file.rb'
      watcher.perform.should be_true
      watcher.perform.should be_false
    end
  end
  
  it 'executes the block when files are changed' do
    within_construct do |c|
      count = 0
      c.file 'machined.rb'
      watcher.perform { count += 1 }
      count.should == 0
      
      modify 'machined.rb'
      watcher.perform { count += 1 }
      count.should == 1
      watcher.perform { count += 1 }
      count.should == 1
    end
  end
  
  if RUBY_VERSION > '1.9'
    it 'unloads required files' do
      within_construct do |c|
        c.file 'lib/hello.rb', 'module Hello; def self.world; "hello"; end; end'
        watcher.perform
        require './lib/hello'
        Hello.world.should == 'hello'
        
        modify 'lib/hello.rb', 'module Hello; def self.world; "world"; end; end'
        watcher.perform
        require './lib/hello'
        Hello.world.should == 'world'
      end
    end
  end
end
