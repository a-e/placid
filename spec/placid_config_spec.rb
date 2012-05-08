require 'spec_helper'

describe Placid::Config do
  after(:each) do
    Placid::Config.rest_url = Placid::Config.default_url
  end

  it "has a default rest_url that is read-only" do
    Placid::Config.rest_url.should == Placid::Config.default_url
    lambda do
      Placid::Config.default_url = 'foo'
    end.should raise_error(NoMethodError)
  end

  it "allows setting rest_url" do
    Placid::Config.rest_url = 'http://www.example.com'
    Placid::Config.rest_url.should == 'http://www.example.com'
  end
end

