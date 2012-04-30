require 'spec_helper'

describe Machined::Reloader do
  let(:reloader) { Machined::Reloader.new(machined) }
  
  def modify(file, content = nil)
    file.open { |f| f.write(conten) } if content
    future = Time.now + 60
    file.utime future, future
  end
  
  it 'knows when the config file changes' do
    within_construct do |c|
      file = c.file 'machined.rb'
      reloader.perform.should be_false
      modify file
      reloader.perform.should be_true
      reloader.perform.should be_false
    end
  end
end
