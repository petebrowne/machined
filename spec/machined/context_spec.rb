require 'spec_helper'

describe Machined::Context do
  describe '#machined' do
    it 'returns a reference to the Machined environment' do
      build_context.machined.should be(machined)
    end
  end
  
  describe '#config' do
    it "returns a reference to the Machined environment's configuration" do
      machined.config.layout = 'application'
      build_context.config.layout.should == 'application'
    end
  end
end
