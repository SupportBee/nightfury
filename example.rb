require 'rubygems'
require 'bundler/setup'
require 'nightfury'

# NightFury makes use Redis.current Redis client
REDIS_CLIENT = Redis.new(:db => 15)
Redis.current = REDIS_CLIENT

# Defining Identity
class CompanyIdentity < Nightfury::Identity::Base
  # Defining metric: 
  # #metric(name, type)
  # type defaults to :value
  metric :first_response_time, :time_series, step: :day
  metric :ticket_count
end


time_now = Time.now

# Identity object requires an unique ID
c = CompanyIdentity.new(1)

# Working with time series
# #set(value, timestamp)
# timestamp defaults to current time
c.first_response_time.set(1) 
c.first_response_time.set(2,time_now - 10)

# #get([timestamp])
# without a timestamp get returns the latest value
# return value is a hash with a key value pair (unix_timestamp, value)
# all return values are strings regardless of their data type at the time of insertion
puts "#get; latest value: \n #{c.first_response_time.get}"
puts "#get(timestamp); value at the timestamp: \n #{c.first_response_time.get(time_now - 10)}"
puts "#get_range(start_time, end_time); returns values with condition start_time >= value <= end_time \n #{c.first_response_time.get_range(time_now - 15, time_now - 5)}"
puts "#get_padded_range(start_time, end_time); returns values with condition start_time >= value <= end_time. Adds padding for missing steps. \n #{c.first_response_time.get_range(time_now - 15, time_now - 5)}"
puts "#get_all; returns all values \n #{c.first_response_time.get_all}"


# Working with values
c.ticket_count.set(0)
# increment by 1
c.ticket_count.incr
# increment by 10
c.ticket_count.incr(10)
# decrement by 1
c.ticket_count.decr
# decrement by 5
c.ticket_count.decr(5)
puts "Ticket Count; should be 5 \n #{c.ticket_count.get}"
