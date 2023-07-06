#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require_relative '../spec_helper'
require_relative '../../lib/oozone/installer'

DummyConf = Struct.new(:raw)

# Test installer class
#
class TestInstaller < MiniTest::Test
  def test_initialize_bad
    assert_output(nil,
                  "'no-such-brand' zones are not supported by Oozone.\n") do
      assert_raises(SystemExit) do
        Oozone::Installer.new(DummyConf.new({ brand: 'no-such-brand' }))
      end
    end
  end
end
