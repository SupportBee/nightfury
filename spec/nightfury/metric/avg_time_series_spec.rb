require 'spec_helper'

describe Nightfury::Metric::AvgTimeSeries do
  describe "#get_padded_range" do
    it "should fill the missing data points" do
      count_series = Nightfury::Metric::AvgTimeSeries.new(:count)
      start_time = Time.new(2013,1,1,0,0,0)
      end_time = start_time + 120
      missing_time = start_time + 60

      count_series.set(1, start_time)
      count_series.set(2, end_time)
      count_series.get_padded_range(start_time, end_time)[missing_time.to_i.to_s].should == "0.0"
    end
  end

  it "should calculate avg in buckets defined by step" do
    avg_metric = Nightfury::Metric::AvgTimeSeries.new(:avg)
    first_bucket_time = Time.now
    next_bucket_time = first_bucket_time + 61 # step is 60 seconds by default
  
    # Add to first bucket
    avg_metric.set(3, first_bucket_time)
    avg_metric.set(2, first_bucket_time)
    avg_metric.set(4, first_bucket_time)
    avg_metric.set(11, first_bucket_time)

    # Add to next bucket
    avg_metric.set(3, next_bucket_time)
    avg_metric.set(2, next_bucket_time)

    avg_metric.get(first_bucket_time).values.first.should == "5.0"
    avg_metric.get(next_bucket_time).values.first.should == "2.5"
  end
end
