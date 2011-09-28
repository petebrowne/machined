# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "machined/version"

Gem::Specification.new do |s|
  s.name        = "machined"
  s.version     = Machined::VERSION
  s.authors     = ["Pete Browne"]
  s.email       = ["me@petebrowne.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "machined"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency             "sprockets",      "~> 2.0"
  s.add_dependency             "sprockets-sass", "~> 0.2"
  s.add_dependency             "activesupport",  "~> 3.1"
  s.add_dependency             "i18n",           "~> 0.6"
  s.add_development_dependency "rspec",          "~> 2.6"
  s.add_development_dependency "rack-test",      "~> 0.6"
  s.add_development_dependency "test-construct", "~> 1.2"
end
