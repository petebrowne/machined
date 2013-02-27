require 'spec_helper'

describe Machined::Sprocket do
  describe '#initialize' do
    it 'keeps a reference to the Machined environment' do
      sprocket = create_sprocket
      sprocket.machined.should be(machined)
    end

    it 'sets the root path' do
      sprocket = create_sprocket
      sprocket.root.should == Pathname.new('.').expand_path.to_s
      sprocket = create_sprocket :root => 'spec/machined'
      sprocket.root.should == Pathname.new('spec/machined').expand_path.to_s
    end
  end

  describe '#context_class' do
    it 'subclasses Machined::Context' do
      sprocket = create_sprocket
      sprocket.context_class.should < Sprockets::Context
      sprocket.context_class.should < Machined::Context
    end
  end

  describe '#use_all_templates' do
    it 'registers available templates as engines' do
      sprocket = create_sprocket :assets => true
      sprocket.engines('.haml').should be_nil
      sprocket.engines('.md').should be_nil
      sprocket.use_all_templates
      sprocket.engines('.haml').should be(Tilt::HamlTemplate)
      sprocket.engines('.md').should be(Tilt::RDiscountTemplate)
    end
  end
end
