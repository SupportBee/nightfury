require 'spec_helper'

describe Nightfury::Metric::TimeSeries do
  describe "#set" do
    context "key does not exist" do
      describe "initialize a time series" do
        it "should add meta data" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)
          ts_metric.set(1)
          ts_metric.meta.should == {}
        end
      end
    end

    describe "add the value to timeline" do
      it "should default time to current time" do
        time_now = Time.now 
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)

        flexmock(ts_metric.redis).should_receive(:zadd)
                                 .with(ts_metric.redis_key, 
                                       time_now.to_i, 
                                       FlexMock.any)
                                 .once

        Timecop.freeze(time_now) do
          ts_metric.set(1)
        end
        Timecop.return
      end

      it "should add at specified time" do
        time = Time.now - 60
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)

        flexmock(ts_metric.redis).should_receive(:zadd)
                                 .with(ts_metric.redis_key, 
                                       time.to_i, 
                                       FlexMock.any)
                                 .once

        ts_metric.set(1, time)
      end

      it "should add the time to the value to avoid duplicate value in the set" do
        time = Time.now
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)

        flexmock(ts_metric.redis).should_receive(:zadd)
                                 .with(FlexMock.any, 
                                       FlexMock.any, 
                                       "#{time.to_i}:1")
                                 .once
        ts_metric.set(1, time)
      end
    end
  end
end
