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

  gem.required_ruby_version = Gem::Requirement.new('>= 3.1.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
