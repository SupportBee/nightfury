require 'spec_helper'

describe Nightfury::Metric::Base do
  it "should have a name" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.name.should == :tickets_count
  end

  it "should have a redis key" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.redis_key.should == "tickets_count"
  end

  it "should use store_as in the redis key instead of name if provided" do
    metric = Nightfury::Metric::Base.new(:tickets_count, store_as: :tc)
    metric.redis_key.should == "tc"
  end

  it "should accept a redis key prefix" do
    metric = Nightfury::Metric::Base.new(:tickets_count, redis_key_prefix: 'prefix')
    metric.redis_key.should == "prefix:tickets_count"
  end

  it "should have nightfury's redis connection" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    metric.redis.should == Nightfury.redis
  end

  it "should be able to remove itself" do
    metric = Nightfury::Metric::Base.new(:tickets_count)
    flexmock(metric.redis).should_receive(:del).with('tickets_count').once
    metric.delete
  end
end
