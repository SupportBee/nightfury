describe Nightfury::Metric::Value do
  it "should get a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:get).with('tickets_count').once
    value_metric.get
  end

  it "should set a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:set).with('tickets_count', 1).once
    value_metric.set(1)
  end

  it "should increment a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:incrby).with('tickets_count', 1).once
    value_metric.incr
  end

  it "should decrement a value by delegating to redis" do
    value_metric = Nightfury::Metric::Value.new(:tickets_count)
    flexmock(value_metric.redis).should_receive(:decrby).with('tickets_count', 2).once
    value_metric.decr(2)
  end
end
