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
  gem.requirements = ["redis, v3.0.0 or greater"]
  gem.version       = Nightfury::VERSION
end
