require 'spec_helper'

describe Placid::Model do
  class Thing < Placid::Model
  end

  context "Instance methods" do
    describe "#id" do
      it "returns the value in the custom unique ID field" do
        class Person < Placid::Model
          unique_id :email
        end
        person_1 = Person.new(:email => 'foo1@bar.com')
        person_2 = Person.new(:email => 'foo2@bar.org')
        person_1.id.should == 'foo1@bar.com'
        person_2.id.should == 'foo2@bar.org'
      end

      it "returns the value in the :id field if no custom field was set" do
        thing_1 = Thing.new(:id => '111')
        thing_2 = Thing.new(:id => '222')
        thing_1.id.should == '111'
        thing_2.id.should == '222'
      end
    end

    describe "#save" do
      it "creates a new instance if one doesn't exist" do
        thing = Thing.new(:id => '123')
        Thing.stub(:find => nil)
        Thing.should_receive(:create).
          with({'id' => '123'}).
          and_return(Thing.new)
        thing.save
      end

      it "updates an existing instance" do
        thing = Thing.new(:id => '123')
        Thing.stub(:find => {:id => '123'})
        Thing.should_receive(:update).
          with('123', {'id' => '123'}).
          and_return(Thing.new)
        thing.save
      end

      it "merges saved attributes on create" do
        thing = Thing.new(:id => '123')
        saved_attribs = {'id' => '123', 'name' => 'foo'}
        Thing.stub(:find => nil)
        Thing.should_receive(:create).
          with({'id' => '123'}).
          and_return(Thing.new(saved_attribs))
        thing.save
        thing.should == saved_attribs
      end

      it "merges saved attributes on update" do
        thing = Thing.new(:id => '123')
        saved_attribs = {'id' => '123', 'name' => 'foo'}
        Thing.stub(:find => {:id => '123'})
        Thing.should_receive(:update).
          with('123', {'id' => '123'}).
          and_return(Thing.new(saved_attribs))
        thing.save
        thing.should == saved_attribs
      end

      it "returns false if errors were reported" do
        thing = Thing.new
        Thing.stub(:find => nil)
        Thing.stub(:request).with(:post, 'thing', {}) { {'errors' => 'Missing id'} }
        thing.save.should be_false
      end

      it "returns true if errors is an empty list" do
        thing = Thing.new(:id => '123')
        Thing.stub(:find => nil)
        Thing.stub(:request).with(:post, 'thing', {'id' => '123'}) { {'errors' => []} }
        thing.save.should be_true
      end

      it "returns true if no errors were reported" do
        thing = Thing.new(:id => '123')
        Thing.stub(:find => nil)
        Thing.stub(:request).with(:post, 'thing', {'id' => '123'}) { {} }
        thing.save.should be_true
      end
    end

    describe "#required?" do
      it "true if the given field is implicitly required" do
        Thing.stub(:meta => {:id => {:required => true}})
        thing = Thing.new
        thing.required?(:id).should == true
      end

      it "false if the given field is explicitly optional" do
        Thing.stub(:meta => {:id => {:required => false}})
        thing = Thing.new
        thing.required?(:id).should == false
      end

      it "false if the given field is implicitly optional" do
        Thing.stub(:meta => {:id => {}})
        thing = Thing.new
        thing.required?(:id).should == false
      end
    end

    describe "#errors=" do
      it "sets the list of errors on the instance" do
        thing = Thing.new
        thing.errors = ['missing id']
        thing['errors'].should == ['missing id']
      end
    end

    describe "#errors" do
      it "returns errors set on initialization" do
        thing = Thing.new(:errors => ['missing id'])
        thing.errors = ['missing id']
        thing.errors.should == ['missing id']
      end

      it "returns errors set after initialization" do
        thing = Thing.new
        thing.errors = ['missing id']
        thing.errors.should == ['missing id']
      end

      it "returns [] if errors are not set" do
        thing = Thing.new
        thing.errors.should == []
      end

      it "returns [] if errors is set to nil" do
        thing = Thing.new
        thing.errors = nil
        thing.errors.should == []
      end
    end

    describe "#errors?" do
      it "returns true if errors is set to a nonempty value" do
        thing = Thing.new(:errors => ['missing id'])
        thing.errors?.should be_true
      end

      it "returns false if errors it not set" do
        thing = Thing.new
        thing.errors?.should be_false
      end

      it "returns false if errors is set to nil" do
        thing = Thing.new
        thing.errors = nil
        thing.errors?.should be_false
      end

      it "returns false if errors is set to an empty list" do
        thing = Thing.new
        thing.errors = []
        thing.errors?.should be_false
      end
    end

    describe "helpers" do
      it "can call #request on an instance" do
        thing = Thing.new
        RestClient.should_receive(:get).
          with('http://localhost/thing/foo', {:params => {:x => 'y'}}).
          and_return('{}')
        thing.request(:get, 'thing', 'foo', :x => 'y')
      end
    end
  end

  context "Class methods" do
    describe "#unique_id" do
      it "returns :id if no ID was set in the derived class" do
        class Default < Placid::Model
        end
        Default.unique_id.should == :id
      end

      it "returns the unique ID that was set in the derived class" do
        class Explicit < Placid::Model
          unique_id :custom
        end
        Explicit.unique_id.should == :custom
      end
    end

    describe "#model" do
      it "converts CamelCase to snake_case" do
        class MyModelName < Placid::Model
        end
        MyModelName.model.should == 'my_model_name'
      end
    end

    describe "#meta" do
      it "returns a Mash of model meta-data" do
        thing_meta = {
          'name' => {'type' => 'String', 'required' => true}
        }
        RestClient.should_receive(:get).
          with('http://localhost/thing/meta', {:params => {}}).
          and_return(JSON(thing_meta))
        Thing.meta.should == thing_meta
      end

      it "only sends a GET meta request once for the class" do
        thing_meta = {
          'name' => {'type' => 'String', 'required' => true}
        }
        RestClient.stub(:get => JSON(thing_meta))
        RestClient.should_receive(:get).at_most(:once)
        Thing.meta.should == thing_meta
        Thing.meta.should == thing_meta
        Thing.meta.should == thing_meta
      end

      it "stores meta-data separately for each derived class" do
        class ThingOne < Placid::Model; end
        class ThingTwo < Placid::Model; end

        thing_one_meta = {
          'one' => {'type' => 'String', 'required' => true}
        }
        RestClient.should_receive(:get).
          with('http://localhost/thing_one/meta', {:params => {}}).
          and_return(JSON(thing_one_meta))
        ThingOne.meta.should == thing_one_meta

        thing_two_meta = {
          'two' => {'type' => 'String', 'required' => false}
        }
        RestClient.should_receive(:get).
          with('http://localhost/thing_two/meta', {:params => {}}).
          and_return(JSON(thing_two_meta))
        ThingTwo.meta.should == thing_two_meta
      end
    end

    describe "#list" do
      it "returns a list of model instances" do
        data = [
          {'name' => 'Foo'},
          {'name' => 'Bar'},
        ]
        RestClient.stub(:get => JSON(data))
        things = Thing.list
        things.should == data
        things.each do |thing|
          thing.should be_a(Thing)
        end
      end
    end

    describe "#find" do
      it "returns a Model instance matching the given id" do
        data = {'name' => 'Foo'}
        RestClient.stub(:get => JSON(data))
        thing = Thing.find(1)
        thing.should be_a(Thing)
        thing.should == data
      end
    end

    describe "#create" do
      context "attributes include" do
        it "posted attributes if no attributes were returned" do
          RestClient.stub(:post => '{}')
          attrs = {'name' => 'Foo'}
          thing = Thing.create(attrs)
          thing.should be_a(Thing)
          thing.should == {'name' => 'Foo'}
        end

        it "returned attributes if no attributes were posted" do
          RestClient.stub(:post => '{"uri": "foo"}')
          attrs = {}
          thing = Thing.create(attrs)
          thing.should be_a(Thing)
          thing.should == {'uri' => 'foo'}
        end

        it "original attributes merged with returned attributes" do
          RestClient.stub(:post => '{"uri": "foo"}')
          attrs = {'name' => 'Foo'}
          thing = Thing.create(attrs)
          thing.should be_a(Thing)
          thing.should == {'name' => 'Foo', 'uri' => 'foo'}
        end
      end

      it "sets errors on the Model instance" do
        data = {'errors' => ['name is required']}
        RestClient.stub(:post => JSON(data))
        thing = Thing.create()
        thing.should be_a(Thing)
        thing.errors.should == ['name is required']
      end
    end

    describe "#update" do
      context "attributes include" do
        it "posted attributes if no attributes were returned" do
          RestClient.stub(:put => '{}')
          attrs = {'name' => 'Foo'}
          result = Thing.update(1, attrs)
          thing = Thing.update(1, attrs)
          thing.should be_a(Thing)
          thing.should == {'name' => 'Foo'}
        end

        it "returned attributes if no attributes were posted" do
          RestClient.stub(:put => '{"uri": "foo"}')
          attrs = {}
          thing = Thing.update(1, attrs)
          thing.should be_a(Thing)
          thing.should == {'uri' => 'foo'}
        end

        it "original attributes merged with returned attributes" do
          RestClient.stub(:put => '{"uri": "foo"}')
          attrs = {'name' => 'Foo'}
          thing = Thing.update(1, attrs)
          thing.should be_a(Thing)
          thing.should == {'name' => 'Foo', 'uri' => 'foo'}
        end
      end

      it "sets errors on the Model instance" do
        data = {'errors' => ['name is required']}
        RestClient.stub(:put => JSON(data))
        thing = Thing.update(1, {})
        thing.should be_a(Thing)
        thing.errors.should == ['name is required']
      end
    end

    describe "#destroy" do
      it "returns the parsed JSON response" do
        data = {'status' => 'ok'}
        RestClient.stub(:delete => JSON(data))
        Thing.destroy(1).should == data
      end
    end
  end
end

