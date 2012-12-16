require 'spec_helper'

describe Nightfury::Identity::Base do
  describe "ClassMethods" do
    it "should have a name" do
      class Dummy < Nightfury::Identity::Base; end
      Dummy.name.should == 'dummy'
    end

    describe "metric" do
      it "should add to metrics" do
        class Dummy < Nightfury::Identity::Base; end
        Dummy.metric(:count)
        Dummy.metrics[:count].should == {type: :value}
      end

      it "should add a instance method" do
        class Dummy < Nightfury::Identity::Base; end
        Dummy.metric(:count)
        Dummy.instance_methods.should include(:count)
      end
    end
  end

  describe "InstanceMethods" do
    it "should have an id" do
      
    end

    it "should generates a key prefix" do
    end
  end
end
