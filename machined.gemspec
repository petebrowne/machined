# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'machined/version'

Gem::Specification.new do |s|
  s.name        = 'machined'
  s.version     = Machined::VERSION
  s.authors     = ['Pete Browne']
  s.email       = ['me@petebrowne.com']
  s.homepage    = 'https://github.com/petebrowne/machined'
  s.summary     = 'A static site generator and Rack server built using Sprockets 2.0'
  s.description = "Why another static site generator? Machined is for the developers who know and love the asset pipeline of Rails 3.1 and want to develop blazingly fast static websites. It's built from the ground up using Sprockets 2.0."

  s.rubyforge_project = 'machined'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency             'sprockets',         '~> 2.6.0'
  s.add_dependency             'sprockets-helpers', '~> 0.7.1'
  s.add_dependency             'sprockets-sass',    '~> 0.9.1'
  s.add_dependency             'padrino-helpers',   '~> 0.10.6'
  s.add_dependency             'activesupport',     '~> 3.2.3'
  s.add_dependency             'i18n',              '~> 0.6.0'
  s.add_dependency             'thor',              '~> 0.15.4'
  s.add_dependency             'crush',             '~> 0.3.3'
  s.add_development_dependency 'rspec',             '~> 2.9.0'
  s.add_development_dependency 'rack-test',         '~> 0.6.1'
  s.add_development_dependency 'test-construct',    '~> 1.2.0'
  s.add_development_dependency 'unindent',          '~> 1.0'
  s.add_development_dependency 'sprockets-plugin',  '~> 0.2.1'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'sass'
  s.add_development_dependency 'slim'
  s.add_development_dependency 'erubis'
  s.add_development_dependency 'rdiscount'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'rake'
end
