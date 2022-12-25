require 'spec_helper'

describe Nightfury::Metric::TimeSeries do
  describe "Initialization" do
    it "should initialize a time series (setup meta data)" do
      ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)
      ts_metric.meta.should == {}
    end
  end

  describe "#meta=" do
    it "should save the meta to redis" do
      ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)
      ts_metric.meta.should == {}
      ts_metric.meta= {'count' => 10}
      ts_metric_reloaded = Nightfury::Metric::TimeSeries.new(:avg_time)
      ts_metric_reloaded.meta.should == {'count' => 10}
    end
  end

  describe "#each_timestamp" do
    it "should iterate through each timestamp between a start and a end time" do
      ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)

      start_time = Time.new(2013,1,1,0,0,0)
      mid_time = start_time + 60
      end_time = mid_time + 60

      expected = [[start_time.to_i, nil], [mid_time.to_i, start_time.to_i], [end_time.to_i, mid_time.to_i]]

      expect { |b|
        ts_metric.each_timestamp(start_time, end_time, &b)
      }.to yield_successive_args(*expected)
    end
  end

  describe "Getter" do
    describe "#get" do
      it "should retrun nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del(ts_metric.redis_key)
        ts_metric.get.should be_nil
      end

      context "with meta" do
        it "should also return the meta part of the data point" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          time_now = Time.now
          ts_metric.set(1, time_now)
          ts_metric.get(time_now, true)[1].should == {}
        end
      end

      context "without timestamp" do
        it "should get the most recent data point" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          time_now = Time.now
          time_later = time_now + 60
          ts_metric.set(1, time_now)
          ts_metric.set(2, time_later)
          result = ts_metric.get
          result.values.first.should == '2'
        end

        it "should return nil if there are no data points" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          ts_metric.get.should be_nil
        end
      end

      context "with timestamp" do
        it "should get the data point at the nearest time step" do
          ts_metric = Nightfury::Metric::TimeSeries.new(:time)
          time_now = Time.now
          time_later = time_now + 60
          ts_metric.set(1, time_now)
          ts_metric.set(2, time_later)
          result = ts_metric.get(time_now)
          result.values.first.should == '1'
        end

        context "no data point at the timestamp" do
          it "should return nil if there are no data points in the time series" do
            ts_metric = Nightfury::Metric::TimeSeries.new(:time)
            ts_metric.get(Time.now).should be_nil
          end

          it "should return the nearest data point in the past" do
            ts_metric = Nightfury::Metric::TimeSeries.new(:time)
            set_time = Time.now - 60
            ts_metric.set(1, set_time)
            result = ts_metric.get(Time.now)
            result.values.first.should == '1'
          end
        end
      end
    end

    describe "#get_exact" do
      it "should get the data_point at the timestamp" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        time = Time.now
        ts_metric.set(1, time)
        result = ts_metric.get_exact(time)
        result.values.first.should == '1'
      end

      it "should return data point's meta if specified" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        time = Time.now
        ts_metric.set(1, time)
        result = ts_metric.get_exact(time, true)
        result[1].should == {}
      end

      it "should return nil if there is no data_point at the timestamp" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        time = Time.now
        ts_metric.set(1, time)
        result = ts_metric.get_exact(time+61)
        result.should be_nil
      end

      it "should retrun nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del(ts_metric.redis_key)
        ts_metric.get_exact(Time.now).should be_nil
      end
    end

    describe "#get_range" do
      it "should return nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del(ts_metric.redis_key)
        ts_metric.get_range(Time.now, Time.now).should be_nil
      end

      it "should return an empty array if no data points are present in the given time range" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        ts_metric.get_range(Time.now, Time.now).should be_empty
      end

      it "should get all data points in the given time range" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        time = Time.utc(2050, 1, 1)
        loop_time = time.dup

        10.times do |i|
          ts_metric.set(i, loop_time)
          loop_time = loop_time + 61
        end

        start_time = time + (3 * 60)
        end_time = time + (5 * 60)

        result = ts_metric.get_range(start_time, end_time)
        result.values.should == ['3', '4', '5']
      end
    end

    describe "#get_all" do
      it "should return nil if metric key on redis is empty" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:time)
        # delete redis key
        ts_metric.redis.del(ts_metric.redis_key)
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
          loop_time = loop_time + 61
        end

        result = ts_metric.get_all
        result.length.should == 10
      end
    end
  end

  describe "Setter" do
    describe "before set" do
      it "should call before_set, before adding the value to the timeline" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)
        time = Time.now
        flexmock(ts_metric).should_receive(:before_set).with(1, time).and_return([1,time]).once
        ts_metric.set(1, time)
      end

      it "should not call before_set, before adding the value to the timeline if optiond ':skip_before_set' is provided" do
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)
        flexmock(ts_metric).should_receive(:before_set).with(1).never
        ts_metric.set(1, Time.now, :skip_before_set => true)
      end
    end

    describe "add the value to timeline" do
      it "should default time to the step near the current time" do
        time_now = Time.now
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)

        flexmock(ts_metric.redis).should_receive(:zadd)
                                 .with(ts_metric.redis_key,
                                       floor_time(time_now, 60).to_i,
                                       FlexMock.any)
                                 .once

        Timecop.freeze(time_now) do
          ts_metric.set(1)
        end
        Timecop.return
      end

      it "should add at the step near to specified time" do
        time = Time.now - 60
        ts_metric = Nightfury::Metric::TimeSeries.new(:avg_time)

        flexmock(ts_metric.redis).should_receive(:zadd)
                                 .with(ts_metric.redis_key,
                                       floor_time(time, 60).to_i,
                                       FlexMock.any)
                                 .once

        ts_metric.set(1, time)
      end
    end
  end
end
