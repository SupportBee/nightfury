require 'spec_helper'

describe Nightfury::Identity::Base do

  class Dummy < Nightfury::Identity::Base
  end

  describe "ClassMethods" do
    it "should have a name" do
      Dummy.name.should == 'dummy'
    end

    describe "metric" do
      it "should add to metrics" do
        Dummy.metric(:count)
        Dummy.metrics[:count].should == {type: :value}
      end

      it "should add a instance method" do
        Dummy.metric(:another_count)
        Dummy.instance_methods.should include(:another_count)
      end
    end
  end

  describe "InstanceMethods" do
    it "should have an id" do
      d = Dummy.new(1)
      d.id.should == 1
    end

    it "should generates a key prefix" do
      d = Dummy.new(1)
      d.key_prefix.should == 'dummy:1'
    end

    it "should use store_as to generate key prefix if provided" do
      d = Dummy.new(1)
      flexmock(Dummy).should_receive(:store_as => :d)
      d.key_prefix.should == 'd:1'
    end

    describe "Dynamically generated metric" do
      it "should instantiate the right metric class" do
        Dummy.metric(:third_count)
        d = Dummy.new(1)
        metric_object = d.third_count
        metric_object.should be_kind_of(Nightfury::Metric::Value)
        metric_object.name.should == :third_count
        metric_object.redis_key_prefix.should == 'dummy:1'
      end
    end
  end
end
