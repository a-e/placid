require 'spec_helper'

describe Placid::Helper do
  describe "#escape" do
    it "escapes all URI reserved characters" do
      escape(";/?:@&=+$,[]").should == "%3B%2F%3F%3A%40%26%3D%2B%24%2C%5B%5D"
    end
  end

  describe "#to_snake_case" do
    it "starts new words for each capitalized word" do
      to_snake_case('Foo').should == 'foo'
      to_snake_case('FooBar').should == 'foo_bar'
      to_snake_case('FooBarBaz').should == 'foo_bar_baz'
    end

    it "treats consecutive capitals as a single word" do
      to_snake_case('FOO').should == 'foo'
      to_snake_case('FOOBar').should == 'foo_bar'
      to_snake_case('FOOBarBAZ').should == 'foo_bar_baz'
    end
  end

  describe "#url" do
    it "joins path components with '/'" do
      url('foo', 'bar', 'baz').should == 'http://localhost/foo/bar/baz'
    end

    it "escapes path components to make them URI-safe" do
      url('a b', 'c:d', 'e/f').should == 'http://localhost/a%20b/c%3Ad/e%2Ff'
    end
  end

  describe "#request" do
    it "returns a legitimate response as JSON" do
      RestClient.stub(:get => '["success"]')
      json = request('get')
      json.should == ["success"]
    end

    it "returns a RestClient::Exception response as JSON" do
      class RestException < RestClient::Exception
        def response; '["fail"]'; end
      end
      RestClient.stub(:get).and_raise(RestException)
      json = request('get')
      json.should == ["fail"]
    end

    it "passes other exceptions through" do
      RestClient.stub(:get).and_raise(URI::InvalidURIError)
      lambda do
        json = request('get')
      end.should raise_error(URI::InvalidURIError)
    end

    it "returns an empty hash if there is no response" do
      RestClient.stub(:get) { nil }
      json = request('get')
      json.should == {}
    end

    it "accepts a params hash as the last argument" do
      RestClient.should_receive(:post).with('http://localhost/foo', {:bar => 'hi'})
      json = request('post', 'foo', :bar => 'hi')
    end

    it "sends an empty params hash if none is given" do
      RestClient.should_receive(:post).with('http://localhost/foo', {})
      json = request('post', 'foo')
    end

    it "sends :params => params for get requests" do
      RestClient.should_receive(:get).with('http://localhost/foo', {:params => {:x => 'y'}})
      json = request('get', 'foo', :x => 'y')
    end
  end

  describe "#get_mash" do
    it "returns a Hashie::Mash for hash data" do
      data = {
        'first_name' => 'Nathan',
        'last_name' => 'Stark',
      }
      RestClient.stub(:get => JSON(data))
      mash = get_mash
      mash.first_name.should == 'Nathan'
      mash.last_name.should == 'Stark'
    end

    it "raises an exception when the JSON cannot be parsed" do
      data = ['a', 'b', 'c']
      RestClient.stub(:get => JSON(data))
      lambda do
        mashes = get_mash
      end.should raise_error(Placid::JSONParseError)
    end
  end

  describe "#get_mashes" do
    it "returns a list of Hashie::Mash for list data" do
      data = [
        {'first_name' => 'Jack', 'last_name' => 'Carter'},
        {'first_name' => 'Allison', 'last_name' => 'Blake'},
      ]
      RestClient.stub(:get => JSON(data))
      mashes = get_mashes
      mashes.first.first_name.should == 'Jack'
      mashes.first.last_name.should == 'Carter'
      mashes.last.first_name.should == 'Allison'
      mashes.last.last_name.should == 'Blake'
    end

    it "raises an exception when the JSON cannot be parsed" do
      data = ['a', 'b', 'c']
      RestClient.stub(:get => JSON(data))
      lambda do
        mashes = get_mashes
      end.should raise_error(Placid::JSONParseError)
    end
  end
end

