#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/oozone/dataset_manager'

# Test the ZFS dataset manager. Assumes you don't have a 'tester' pool with a
# 'test-zone' dataset.
#
class TestDatasetManager < Minitest::Test
  def setup
    @t = Oozone::DatasetManager.new('tester/test-zone')
  end

  def test_create!
    execute = Spy.on(@t, :execute!)
    @t.create!
    assert_equal(1, execute.calls.size)
    assert_equal(['/usr/sbin/zfs create -o mountpoint=none tester/test-zone'],
                 execute.calls.first.args)
  end

  def test_exist?
    refute @t.exist?

    execute = Spy.on(@t, :executes_successfully?).and_return(true)
    assert @t.exist?
    execute.unhook
  end
end
