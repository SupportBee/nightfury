# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nightfury/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Avinasha Shastry", "Prateek Dayal"]
  gem.email         = ["me@avinasha.com", "prateek@supportbee.com"]
  gem.description   = %q{Nightfury is a reporting/analytics backend written on Redis}
  gem.summary       = %q{Nightfury is a reporting/analytics backend written on Redis}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nightfury"
  gem.require_paths = ["lib"]
  gem.requirements  = ["redis, v3.0.0 or greater"]
  gem.version       = Nightfury::VERSION
  gem.add_dependency("redis", "~> 3.0")
  gem.add_dependency("redis-namespace", "1.5.2") # Temporarily using the same gem version as the core app
  gem.add_dependency("activesupport", "~> 3.0.0")
  gem.add_dependency("i18n")
  gem.add_dependency("json", "1.8.3") # Temporarily using the same gem version as the core app
  gem.add_development_dependency("rspec")
  gem.add_development_dependency("flexmock", "1.0.4") # Temporarily using the same gem version as the core app
  gem.add_development_dependency("timecop")
  gem.add_development_dependency("pry")
end
