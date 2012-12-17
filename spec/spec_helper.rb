require 'rubygems'
require 'bundler/setup'

require 'nightfury'
require 'timecop'

# Start our own redis-server to avoid corrupting any others
REDIS_BIN  = 'redis-server'
REDIS_PORT = ENV['REDIS_PORT'] || 9212
REDIS_HOST = ENV['REDIS_HOST'] || 'localhost'
REDIS_PID  = File.expand_path 'redis.pid', File.dirname(__FILE__)
REDIS_DUMP = File.expand_path 'redis.rdb', File.dirname(__FILE__)
puts "=> Starting redis-server on #{REDIS_HOST}:#{REDIS_PORT}"
fork_pid = fork do
  system "(echo port #{REDIS_PORT}; echo logfile /dev/null; echo daemonize yes; echo pidfile #{REDIS_PID}; echo dbfilename #{REDIS_DUMP}) | #{REDIS_BIN} -"
end
at_exit do
  pid = File.read(REDIS_PID).to_i
  puts "=> Killing #{REDIS_BIN} with pid #{pid}"
  Process.kill "TERM", pid
  Process.kill "KILL", pid
  File.unlink REDIS_PID
  File.unlink REDIS_DUMP if File.exists? REDIS_DUMP
end

REDIS_CLIENT = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
Redis.current = REDIS_CLIENT

RSpec.configure do |config|
  config.mock_with :flexmock

  config.before(:each) do
    REDIS_CLIENT.flushdb
  end
end
