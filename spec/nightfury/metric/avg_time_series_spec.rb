require 'spec_helper'

describe Nightfury::Metric::AvgTimeSeries do
  it "should have the right default meta" do
    avg_metric = Nightfury::Metric::AvgTimeSeries.new(:avg)
    avg_metric.default_meta.should == { 'count' => 0.0, 'total' => 0.0 }
  end

  it "should calculate avg before saving" do
    avg_metric = Nightfury::Metric::AvgTimeSeries.new(:avg)
    avg_metric.set(3)
    avg_metric.set(2)
    avg_metric.set(4)
    avg_metric.set(11)
    avg_metric.get.values.first.should == "5.0"
  end

  it "should update meta update count" do
    avg_metric = Nightfury::Metric::AvgTimeSeries.new(:avg)
    avg_metric.set(1)
    avg_metric.set(2)
    avg_metric.meta['count'].should == 2
  end
end
