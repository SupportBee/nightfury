require 'spec_helper'

describe Nightfury::Metric::CountTimeSeries do
  describe "Incr" do
    context "Has data points" do
      it "should be able to increment value by 1 at the current timestamp by default" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        # Add a data point
        count_series.set(1, time_now - 10)

        Timecop.freeze(time_now) do
          count_series.incr
        end
        Timecop.return

        count_series.get.values.first.should == "2"
      end

      it "should be able to increment value by a given step" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        # Add a data point
        count_series.set(1, time_now - 10)

        Timecop.freeze(time_now) do
          count_series.incr(2)
        end
        Timecop.return

        count_series.get.values.first.should == "3"
      end


      it "should be able to increment value at a step near the given timestamp" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        time_later = time_now + 61
        # Add a data point
        count_series.set(1, time_now - 10)
        count_series.incr(1,time_later)
        count_series.get.should == { floor_time(time_later, 60).to_i.to_s => "2"}
      end
    end

    context "Has no data points" do
      it "should add a data point with the given step" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        count_series.incr(2, time_now)
        count_series.get.should == { floor_time(time_now, 60).to_i.to_s => "2"}
      end
    end
  end
  
  describe "Decr" do
    context "Has data points" do
      it "should be able to decrement value by 1 at a step near the current timestamp by default" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        # Add a data point
        count_series.set(1, time_now - 61)

        Timecop.freeze(time_now) do
          count_series.decr
        end
        Timecop.return

        count_series.get.values.first.should == "0"
      end

      it "should be able to decrement value by a given step" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        # Add a data point
        count_series.set(2, time_now - 61)

        Timecop.freeze(time_now) do
          count_series.decr(2)
        end
        Timecop.return

        count_series.get.values.first.should == "0"
      end


      it "should be able to decrement value at nearest step of a given timestamp" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        time_later = time_now + 61
        # Add a data point
        count_series.set(1, time_now - 10)
        count_series.decr(1,time_later)
        count_series.get.should == { floor_time(time_later, 60).to_i.to_s => "0"}
      end
    end

    context "Has no data points" do
      it "should add a data point with the given step" do
        count_series = Nightfury::Metric::CountTimeSeries.new(1)
        time_now = Time.now
        count_series.decr(2, time_now)
        count_series.get.should == { floor_time(time_now, 60).to_i.to_s => "-2"}
      end
    end
  end
end
