# frozen_string_literal: true

require 'logger'
require 'pathname'
require 'minitest/autorun'
require 'spy/integration'

RES_DIR = Pathname.new(__dir__).join('resources')
LOG = Logger.new('/dev/null')

# @return [String] contents of given file
#
def contents_of(file)
  File.read(RES_DIR.join(file))
end
