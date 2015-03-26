require 'spec_helper'

describe Hoge do
  it "should print String" do
    expect(Hoge.new.puts).to be_instance_of String
  end 
end