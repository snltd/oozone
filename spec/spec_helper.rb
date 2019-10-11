# frozen_string_literal: true

require 'logger'
require 'pathname'
require 'minitest/autorun'
require 'mocha/minitest'

RES_DIR = Pathname.new(__dir__) + 'resources'
LOG = Logger.new('/dev/null')
