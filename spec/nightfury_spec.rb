require 'spec_helper'

describe Nightfury do
  describe "redis setup" do
    it "should default redis connection to Redis.current" do
      Nightfury.redis.client.host.should == "localhost"
      Nightfury.redis.client.port.should == 9212
      Nightfury.redis.client.db.should == 0
    end

    it "should accept a redis connection" do
      redis = Redis.new
      Nightfury.redis = redis
      
      Nightfury.redis.client.host.should == "127.0.0.1"
      Nightfury.redis.client.port.should == 6379
      Nightfury.redis.client.db.should == 0
    end

    it "should default redis namespace to 'nf'" do
      Nightfury.redis.namespace.should == :nf
    end

    it "should set redis namespace to the specified namespace" do
      Nightfury.namespace = :new_nf
      Nightfury.redis.namespace.should == :new_nf
    end
  end
end
