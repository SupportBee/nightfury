require 'spec_helper'

describe Nightfury::Metric::Base do
  it "should have a name" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.name.should == :tickets_count
  end

  it "should have a redis key" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.redis_key.should == "metric:tickets_count"
  end

  it "should accept a redis key prefix" do
    metric = Nightfury::Metric::Base.new(:tickets_count, redis_key_prefix: 'prefix')
    metric.redis_key.should == "prefix:metric:tickets_count"
  end

  it "should have nightfury's redis connection" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.redis.should == Nightfury.redis
  end
end

describe Nightfury::Metric::Value do
  it "should get a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:get).with('metric:tickets_count').once
    value_metric.get
  end

  it "should set a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:set).with('metric:tickets_count', 1).once
    value_metric.set(1)
  end

  it "should increment a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:incr).with('metric:tickets_count').once
    value_metric.incr
  end

  it "should decrement a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:decr).with('metric:tickets_count').once
    value_metric.decr
  end
end


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
