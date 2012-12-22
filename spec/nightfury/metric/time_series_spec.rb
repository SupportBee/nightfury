require 'spec_helper'

describe Nightfury::Metric::TimeSeries do
  describe "Initialization" do
    it "should initialize a time series (setup meta data)" do
      ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)
      ts_metric.meta.should == {}
    end
  end

  describe "Getter" do
    describe "#get" do
      it "should retrun nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del ts_metric.redis_key
        ts_metric.get.should be_nil
      end

      context "without timestamp" do
        it "should get the most recent data point" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          time_now = Time.now
          time_later = time_now + 10
          ts_metric.set(1, time_now)
          ts_metric.set(2, time_later)
          result = ts_metric.get
          result[time_later.to_i.to_s].should == '2'
        end

        it "should return nil if there are no data points" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          ts_metric.get.should be_nil
        end
      end

      context "with timestamp" do
        it "should get the data point at the time stamp" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          time_now = Time.now
          time_later = time_now + 10
          ts_metric.set(1, time_now)
          ts_metric.set(2, time_later)
          result = ts_metric.get(time_now)
          result[time_now.to_i.to_s].should == '1'
        end

        context "no data point at the timestamp" do
          it "should return nil if there are no data points in the time series" do
            ts_metric = Nightfury::Metric::TimeSeries.new(:time)
            ts_metric.get(Time.now).should be_nil
          end

          it "should return the nearest data point" do
            ts_metric = Nightfury::Metric::TimeSeries.new(:time)
            set_time = Time.now - 60
            ts_metric.set(1, set_time)
            result = ts_metric.get(Time.now)
            result[set_time.to_i.to_s].should == '1'
          end
        end
      end
    end

    describe "#get_range" do
      it "should retrun nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del ts_metric.redis_key
        ts_metric.get_range(Time.now, Time.now).should be_nil
      end

      it "should return an empty array if no data points are present in the specified ranges" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        ts_metric.get_range(Time.now, Time.now).should be_empty
      end

      it "should get all data points between the specified ranges" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        time = Time.now
        loop_time = time.dup

        10.times do |i|
          ts_metric.set(i, loop_time)
          loop_time = loop_time + 1
        end

        start_time = time + 3
        end_time = time + 5

        result = ts_metric.get_range(start_time, end_time)
        result[start_time.to_i.to_s].should == '3'
        result[(start_time.to_i + 1).to_s].should == '4'
        result[end_time.to_i.to_s].should == '5'
      end
    end

    describe "#get_all" do
      it "should return nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del ts_metric.redis_key
        ts_metric.get_all.should be_nil
      end

      it "should return an empty array of there are no data points" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        ts_metric.get_all.should be_empty
      end

      it "should get all the data points in the series" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        time = Time.now
        loop_time = time.dup

        10.times do |i|
          ts_metric.set(i, loop_time)
          loop_time = loop_time + 1
        end

        result = ts_metric.get_all
        result.length.should == 10
      end
    end
  end

  describe "Setter" do
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
