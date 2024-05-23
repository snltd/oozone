#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/oozone/helpers'

# Test helper methods
#
class TestHelpers < Minitest::Test
  def test_execute_command
    assert_output(nil, "Unsupported command.\n") do
      assert_raises(SystemExit) do
        Oozone::Helpers.execute_command('cmd', 'arg', '-v')
      end
    end
  end

  def test_logger_object
    obj = Oozone::Helpers.logger_object(logfile: '/tmp/log',
                                        loglevel: Logger::INFO)
    assert_instance_of(Logger, obj)
    assert_equal(1, obj.level)
  end
end
