[![Stories in Ready](https://badge.waffle.io/avinasha/nightfury.png)](http://waffle.io/avinasha/nightfury)

# Nightfury

## Concept

Nightfury provides a reporting framework built on Redis for Ruby/Ruby on Rails applications. The framework is designed 
to store different metrics in a time series or as a single value which can be easily queried. 
The following are the key terms:

### Identity

A identity is an entity for which you want to store reports.

* In a ticketing system this might be `Company` or a `Ticket` or an `Agent`
* It has an id (can auto-generate but generally provided so you can map it to your db ids etc). So each `Company` can have its own `CompanyIdentity`
* It has many metrics. 

### Metrics

An identity has many metrics.

* Metric can be a single value or a time series.
* The value can be aggregate (average)

### Tags

Identities can be tagged and have multiple tags.
You can ask for stats for identities with certain tags over a particular time range (if the metric is a series)

## Usage

Lets have a `CompanyIdentity` to track metrics of a company
```
  class CompanyIdentity < Nightfury::Identity::Base
    metric :number_of_users
    metric :tickets_count, :count_time_series, step: :day
    metric :first_response_time, :avg_time_series, step: :day
  end
```

### Single Valued Metric

You can store single valued metric, generally used to store counts. In the above example `number_of_users` is a single valued metric. You can do the following operations on the metric.

```
  c = CompanyIdentity.new(1) # where 1 is the id
  c.number_of_users.set(0)
  # increment by 1
  c.number_of_users.incr
  # increment by 10
  c.number_of_users.incr(10)
  # decrement by 1
  c.number_of_users.decr
  # decrement by 5
  c.number_of_users.decr(5)
  puts "Ticket Count; should be 5 \n #{c.ticket_count.get}"
```

### Time Series Metric

You can track a metric over time. NightFury stores the values in an time series. You can define the period between the day points using the `step` parameter.  

#### Count Time Series Metric

In the above example `tickets_count` is a `count_time_series` with a step `day`. You can do the following operations on the metric.

```
  time_now = Time.now
  yesterday = time_now - 1.day
  tomorrow = time_now + 1.day
  # Increment yesterday's ticket count by 1
  c.tickets_count.incr(1, yesterday) 
  # Increment yesterday's ticket count by 2
  c.tickets_count.incr(1, yesterday) 
  # Decrement yesterday's ticket count by 1
  c.tickets_count.decr(1, yesterday)
  # Increment today's ticket count by 1
  # By default the incr_by argument is 1 and timestamp argument is Time.now
  # NightFury figures out the right datapoint to act on depending the timestamp and step of the metric
  c.tickets_count.incr
  # Get all datapoints between yesterday and tomorrow
  c.tickets_count.get_range(yesterday, tomorrow)
  # Get all datapoints
  c.tickets_count.get_all
```

#### Avg Time Series Metric

NightFury also supports `avg_time_series`. When you set a value of a `avg_time_series` metric, NightFury atomatically calculates the average for that step and stores it.

```
  # set the first_response_time of today
  c.first_response_time.set(1)
  c.first_response_time.set(2)
  # get the latest data point
  c.get #=> {'1380176549' => '1.5'}
```
**See example.rb for more usage**

## Installation

Add this line to your application's Gemfile:

    gem 'nightfury'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nightfury

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
