require 'spec_helper'

describe Placid::Helper do
  before(:each) do
    #CMA.rest_url = 'fake'
  end

  describe "#escape" do
    it "escapes all URI reserved characters" do
      escape(";/?:@&=+$,[]").should == "%3B%2F%3F%3A%40%26%3D%2B%24%2C%5B%5D"
    end
  end

  describe "#url" do
    it "joins path components with '/'" do
      url('foo', 'bar', 'baz').should == 'fake/foo/bar/baz'
    end

    it "escapes path components to make them URI-safe" do
      url('a b', 'c:d', 'e/f').should == 'fake/a%20b/c%3Ad/e%2Ff'
    end
  end

  describe "#request" do
    it "returns a legitimate response as JSON" do
      RestClient.stub(:get) { '["success"]' }
      json = request('get')
      json.should == ["success"]
    end

    it "returns the exception response as JSON" do
      class BadRequest < RuntimeError
        def response; '["fail"]'; end
      end
      RestClient.stub(:get) { raise BadRequest }
      json = request('get')
      json.should == ["fail"]
    end

    it "returns an empty hash if there is no response" do
      RestClient.stub(:get) { nil }
      json = request('get')
      json.should == {}
    end

    it "accepts a params hash as the last argument" do
      RestClient.should_receive(:post).with('fake/foo', {:bar => 'hi'})
      json = request('post', 'foo', :bar => 'hi')
    end

    it "sends an empty params hash if none is given" do
      RestClient.should_receive(:post).with('fake/foo', {})
      json = request('post', 'foo')
    end

    it "sends :params => params for get requests" do
      RestClient.should_receive(:get).with('fake/foo', {:params => {:x => 'y'}})
      json = request('get', 'foo', :x => 'y')
    end
  end
end

