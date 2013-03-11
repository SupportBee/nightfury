require 'spec_helper'

describe Nightfury::Metric::CountTimeSeries do
  describe "#get_padded_range" do
    it "should fill the missing data points with zero" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      start_time = Time.new(2013,1,1,0,0,0)
      end_time = start_time + 120
      missing_time = start_time + 60

      count_series.set(1, start_time)
      count_series.set(2, end_time)
      count_series.get_padded_range(start_time, end_time)[missing_time.to_i.to_s].should == "0"
    end
  end

  describe "Incr" do
    it "should increment the count at the step time of the given timestamp" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      #Add a data point
      count_series.set(2, time_now)
      
      count_series.incr(2, time_now)

      count_series.get.values.first.should == "4"
    end
  
    it "should increment the count at the step time of the current time by default" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      #Add a data point
      count_series.set(2, time_now)
      
      Timecop.freeze(time_now) do
        count_series.incr(2)
      end
      Timecop.return

      count_series.get.values.first.should == "4"
    end

    it "should increment the count by 1 by default" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      #Add a data point
      count_series.set(2, time_now)
      
      Timecop.freeze(time_now) do
        count_series.incr
      end
      Timecop.return

      count_series.get.values.first.should == "3"
    end

    it "should set the count to the step when there is no data point at the step time" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      count_series.incr(1, time_now)
      count_series.get(time_now).values.first.should == "1"
    end

    it "should increment the right step bucket" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      first_step_bucket = Time.now
      second_step_bucket = Time.now + 61

      count_series.set(5, first_step_bucket)
      count_series.set(6, second_step_bucket)

      count_series.incr(1, first_step_bucket)
      count_series.incr(1, second_step_bucket)

      count_series.get(first_step_bucket).values.first.should == "6"
      count_series.get(second_step_bucket).values.first.should == "7"
    end
  end
  
  describe "Decr" do
    it "should decrement the count at the step time of the given timestamp" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:counter)
      time_now = Time.now
      
      #Add a data point
      count_series.set(2, time_now)

      count_series.decr(2, time_now)

      count_series.get.values.first.should == "0"
    end
  
    it "should decrement the count at the step time of the current time by default" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      #Add a data point
      count_series.set(2, time_now)
      
      Timecop.freeze(time_now) do
        count_series.decr(2)
      end
      Timecop.return

      count_series.get.values.first.should == "0"
    end

    it "should decrement the count by 1 by default" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      #Add a data point
      count_series.set(2, time_now)
      
      Timecop.freeze(time_now) do
        count_series.decr
      end
      Timecop.return

      count_series.get.values.first.should == "1"
    end

    it "should set the count to the step when there is no data point at the step time" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      time_now = Time.now
      count_series.decr(1, time_now)
      count_series.get(time_now).values.first.should == "-1"
    end

    it "should decrement the right step bucket" do
      count_series = Nightfury::Metric::CountTimeSeries.new(:count)
      first_step_bucket = Time.now
      second_step_bucket = Time.now + 61

      count_series.set(5, first_step_bucket)
      count_series.set(6, second_step_bucket)

      count_series.decr(1, first_step_bucket)
      count_series.decr(1, second_step_bucket)

      count_series.get(first_step_bucket).values.first.should == "4"
      count_series.get(second_step_bucket).values.first.should == "5"
    end
  end
end
