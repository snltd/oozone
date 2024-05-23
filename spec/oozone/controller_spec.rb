#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/oozone/controller'

# Test the controller
#
class TestController < Minitest::Test
  def setup
    @t = Oozone::Controller.new('test-zone')
    @execute = Spy.on(@t, :execute!)
    @log = Spy.on(LOG, :info)
  end

  def teardown
    @execute.unhook
    @log.unhook
  end

  def test_delete
    @t.delete
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zonecfg -z test-zone delete -F'],
                 @execute.calls.first.args)
    assert_equal(1, @log.calls.count)
    assert_equal(["Deleting 'test-zone' zone"], @log.calls.first.args)
  end

  def test_configure
    @t.configure
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zonecfg -z test-zone -f /var/tmp/test-zone.zone'],
                 @execute.calls.first.args)
    assert_equal(1, @log.calls.count)
    assert_equal(["Configuring 'test-zone' zone"], @log.calls.first.args)
  end

  def test_uninstall
    @t.uninstall
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm -z test-zone uninstall -F'],
                 @execute.calls.first.args)
    assert_equal(1, @log.calls.count)
    assert_equal(["Uninstalling 'test-zone' zone"], @log.calls.first.args)
  end

  def test_boot
    @t.boot
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm -z test-zone boot'],
                 @execute.calls.first.args)
    assert_equal(1, @log.calls.count)
    assert_equal(["Booting 'test-zone' zone"], @log.calls.first.args)
  end

  def test_halt
    @t.halt
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm -z test-zone halt'],
                 @execute.calls.first.args)
    assert_equal(1, @log.calls.count)
    assert_equal(["Halting 'test-zone' zone"], @log.calls.first.args)
  end

  def test_shutdown
    @t.shutdown
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm -z test-zone shutdown'],
                 @execute.calls.first.args)
    assert_equal(1, @log.calls.count)
    assert_equal(["Shutting down 'test-zone' zone"], @log.calls.first.args)
  end

  def test_zone_list
    @t.zone_list
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm list -cp'], @execute.calls.first.args)
  end

  def test_state_for_existing_zone
    list = Spy.on(@t, :zone_list).and_return(contents_of('zone_list'))
    assert_equal('running', @t.state)
    list.unhook
  end

  def test_state_for_non_existent_zone
    list = Spy.on(@t, :zone_list)
              .and_return('0:global:running:/::ipkg:shared:0')

    assert_nil @t.state
    list.unhook
  end

  def test_teardown_does_not_exist
    list = Spy.on(@t, :zone_list).and_return(
      '4:serv-ws:running:/:f56c0dd9-d8d0-44ab-c929-c7aab6df767c:native:excl:0'
    )

    assert_nil @t.teardown
    assert_empty @execute.calls
    list.unhook
  end

  def test_teardown_configured
    list = Spy.on(@t, :zone_list).and_return(zone_list_line(:configured))
    @t.teardown

    assert_equal(['/usr/sbin/zonecfg -z test-zone delete -F'],
                 @execute.calls.first.args)
    list.unhook
  end

  private

  def zone_list_line(state)
    "4:test-zone:#{state}:/:f56c0dd9-d8d0-44ab-c929-c7aab6df767c:native:excl:0"
  end
end
