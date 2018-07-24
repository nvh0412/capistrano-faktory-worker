lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/faktory/version'

Gem::Specification.new do |spec|
  spec.name = 'capistrano-faktory-worker'
  spec.version = Capistrano::FaktoryVERSION
  spec.authors = ['Hoa Nguyen']
  spec.email = ['nvh0412@gmail.com']
  spec.summary = %q{Faktory Worker integration for Capistrano}
  spec.description = %q{Faktory Worker integration for Capistrano}
  spec.homepage = 'https://github.com/nvh0412/capistrano-faktory-worker'
  spec.license = 'LGPL-3.0'

  spec.required_ruby_version     = '>= 2.0.0'
  spec.files = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '>= 3.9.0'
  spec.add_dependency 'faktory_worker_ruby', '>= 0.7.0'
end
