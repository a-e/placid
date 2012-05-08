require 'spec_helper'

describe Placid::Config do
  it "allows setting rest_url" do
    Placid::Config.rest_url = 'http://www.example.com'
    Placid::Config.rest_url.should == 'http://www.example.com'
  end
end

