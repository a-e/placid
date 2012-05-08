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
          and_return({})
        thing.save
      end

      it "updates an existing instance" do
        thing = Thing.new(:id => '123')
        Thing.stub(:find => {:id => '123'})
        Thing.should_receive(:update).
          with('123', {'id' => '123'}).
          and_return({})
        thing.save
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

      it "raises an error if there is no such field"
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
        data = {
          'name' => {'type' => 'String', 'required' => true}
        }
        RestClient.stub(:get => JSON(data))
        Thing.meta.should == data
      end
    end

    describe "#list" do
      it "returns a Mash list of all model instances" do
        data = [
          {'name' => 'Foo'},
          {'name' => 'Bar'},
        ]
        RestClient.stub(:get => JSON(data))
        Thing.list.should == data
      end
    end

    describe "#get" do
      it "returns a Model instance matching the given id" do
        data = {'name' => 'Foo'}
        RestClient.stub(:get => JSON(data))
        Thing.find(1).should == data
      end
    end

    describe "#create" do
      it "returns a Model instance" do
        RestClient.stub(:post => '{}')
        attrs = {'name' => 'Foo'}
        Thing.create(attrs).should == attrs
      end

      it "sets errors on the Model instance" do
        data = {'errors' => ['name is required']}
        RestClient.stub(:post => JSON(data))
        Thing.create().errors.should == ['name is required']
      end
    end

    describe "#update" do
      it "returns a Model instance" do
        RestClient.stub(:put => '{}')
        attrs = {'name' => 'Foo'}
        Thing.update(1, attrs).should == attrs
      end

      it "sets errors on the Model instance" do
        data = {'errors' => ['name is required']}
        RestClient.stub(:put => JSON(data))
        Thing.update(1, {}).errors.should == ['name is required']
      end
    end

    describe "#delete" do
      it "returns the parsed JSON response" do
        data = {'status' => 'ok'}
        RestClient.stub(:delete => JSON(data))
        Thing.destroy(1).should == data
      end
    end
  end
end

