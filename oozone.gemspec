# frozen_string_literal: true

require 'pathname'
require 'date'

require_relative 'lib/oozone/version'

Gem::Specification.new do |gem|
  gem.name          = 'oozone'
  gem.version       = OOZONE_VERSION

  gem.summary       = 'OmniOS zone manager'
  gem.description   = 'Tool to simplify zone create on OmniOS'

  gem.authors       = ['Robert Fisher']
  gem.email         = 'services@id264.net'
  gem.homepage      = 'https://github.com/snltd/oozone'
  gem.license       = 'BSD-2-Clause'

  gem.bindir        = 'bin'
  gem.files         = `git ls-files`.split("\n")
  gem.executables   = 'oozone'
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = %w[lib]

  gem.add_development_dependency 'minitest', '~> 5.11'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rubocop', '~> 1.0'
  gem.add_development_dependency 'rubocop-minitest'
  gem.add_development_dependency 'rubocop-performance'
  gem.add_development_dependency 'rubocop-rake'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
