#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/oozone/config_loader'

# Test the config loader via its public interface.
#
class ConfigLoaderTest < MiniTest::Test
  def setup
    Oozone::DatasetManager.any_instance.stubs(:create).returns(true)
  end
end
