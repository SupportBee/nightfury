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
