require 'spec_helper'

describe Machined::Initializable do
  class BasicInitializer
    include Machined::Initializable
    attr_accessor :count
  end

  after(:each) do
    BasicInitializer.instance_variable_set :@initializers, nil
  end

  it 'runs initializers in order' do
    array = []
    BasicInitializer.initializer(:one) { array << 1 }
    BasicInitializer.initializer(:two) { array << 2 }
    BasicInitializer.initializer(:three) { array << 3 }
    BasicInitializer.new.run_initializers
    array.should == [ 1, 2, 3 ]
  end

  # it 'runs initializers only once' do
  #   count = 0
  #   BasicInitializer.initializer(:count) { count += 1 }
  #   basic = BasicInitializer.new
  #   basic.run_initializers
  #   basic.run_initializers
  #   count.should == 1
  # end

  it 'executes in the instance scope' do
    BasicInitializer.initializer(:init_count) { @count = 0 }
    BasicInitializer.initializer(:one) { @count += 1 }
    BasicInitializer.initializer(:two) { @count += 1 }
    basic = BasicInitializer.new
    basic.run_initializers
    basic.count.should == 2
  end

  it 'runs the initializers with the given args' do
    BasicInitializer.initializer(:sum) { |*args| @count = args.inject(&:+) }
    basic = BasicInitializer.new
    basic.run_initializers 1, 2, 3
    basic.count.should == 6
  end

  it 'adds initializers after specific initializers' do
    array = []
    BasicInitializer.initializer(:one) { array << 1 }
    BasicInitializer.initializer(:two) { array << 2 }
    BasicInitializer.initializer(:three, :after => :one) { array << 3 }
    BasicInitializer.new.run_initializers
    array.should == [ 1, 3, 2 ]
  end

  it 'adds initializers before specific initializers' do
    array = []
    BasicInitializer.initializer(:one) { array << 1 }
    BasicInitializer.initializer(:two) { array << 2 }
    BasicInitializer.initializer(:three, :before => :two) { array << 3 }
    BasicInitializer.new.run_initializers
    array.should == [ 1, 3, 2 ]
  end

  it "raises an error if the specified initializer doesn't exist" do
    expect {
      BasicInitializer.initializer(:wtf, :after => :omg) { }
    }.to raise_error('The specified initializer, :omg, does not exist')

    expect {
      BasicInitializer.initializer(:omg, :before => :wtf) { }
    }.to raise_error('The specified initializer, :wtf, does not exist')
  end
end
