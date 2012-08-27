require 'spec_helper'

describe Placid::Helper do
  describe "#escape" do
    it "escapes all URI reserved characters" do
      escape(";/?:@&=+$,[]").should == "%3B%2F%3F%3A%40%26%3D%2B%24%2C%5B%5D"
    end
  end

  describe "#get_url" do
    it "joins path components with '/'" do
      get_url('foo', 'bar', 'baz').should == 'http://localhost/foo/bar/baz'
    end

    it "escapes path components to make them URI-safe" do
      get_url('a b', 'c:d', 'e/f').should == 'http://localhost/a%20b/c%3Ad/e%2Ff'
    end
  end

  describe "#request" do
    it "accepts a string for method" do
      RestClient.stub(:get => '["success"]')
      json = request('get')
      json.should == ["success"]
    end

    it "accepts a symbol for method" do
      RestClient.stub(:get => '["success"]')
      json = request(:get)
      json.should == ["success"]
    end

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

    it "returns a RestConnectionError when connection is refused" do
      RestClient.stub(:get).and_raise(Errno::ECONNREFUSED)
      lambda do
        json = request('get')
      end.should raise_error(Placid::RestConnectionError, /Could not connect/)
    end

    it "passes other exceptions through" do
      RestClient.stub(:get).and_raise(URI::InvalidURIError)
      lambda do
        json = request('get')
      end.should raise_error(URI::InvalidURIError)
    end

    it "raises a JSONParseError if there is no response" do
      RestClient.stub(:get) { nil }
      lambda do
        json = request('get')
      end.should raise_error(Placid::JSONParseError, /Cannot parse/)
    end

    it "accepts a params hash as the last argument" do
      RestClient.should_receive(:post).
        with('http://localhost/foo', {:bar => 'hi'}).
        and_return('{}')
      json = request('post', 'foo', :bar => 'hi')
    end

    it "sends an empty params hash if none is given" do
      RestClient.should_receive(:post).
        with('http://localhost/foo', {}).
        and_return('{}')
      json = request('post', 'foo')
    end

    it "sends :params => params for get requests" do
      RestClient.should_receive(:get).
        with('http://localhost/foo', {:params => {:x => 'y'}}).
        and_return('{}')
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
      mash.should be_a(Hashie::Mash)
      mash.first_name.should == 'Nathan'
      mash.last_name.should == 'Stark'
    end

    it "returns nested Hashie::Mashes for nested hash data" do
      data = {
        'person' => {
          'first_name' => 'Jack',
          'last_name' => 'Carter',
        },
        'address' => {
          'street' => '123 Main Street',
          'city' => 'Eureka',
        },
      }
      RestClient.stub(:get => JSON(data))
      mash = get_mash
      mash.should be_a(Hashie::Mash)
      mash.person.should be_a(Hashie::Mash)
      mash.person.first_name.should == 'Jack'
      mash.person.last_name.should == 'Carter'
      mash.address.should be_a(Hashie::Mash)
      mash.address.street.should == '123 Main Street'
      mash.address.city.should == 'Eureka'
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

