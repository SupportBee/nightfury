require 'spec_helper'

describe Nightfury::Metric::Base do
  it "should have a name" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.name.should == :tickets_count
  end
end
