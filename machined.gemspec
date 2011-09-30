# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "machined/version"

Gem::Specification.new do |s|
  s.name        = "machined"
  s.version     = Machined::VERSION
  s.authors     = ["Pete Browne"]
  s.email       = ["me@petebrowne.com"]
  s.homepage    = ""
  s.summary     = %q{A static site generator and Rack server built using Sprockets 2.0}
  s.description = %q{Why another static site generator? Machined is for the developers who know and love the asset pipeline of Rails 3.1 and want to develop blazingly fast static websites. It's built from the ground up using Sprockets 2.0.}

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
  s.add_development_dependency 'unindent',       "~> 1.0"
  s.add_development_dependency "haml",           "~> 3.1"
  s.add_development_dependency "sass",           "~> 3.1"
  s.add_development_dependency "rdiscount"
  s.add_development_dependency "rake"
end
