#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/oozone/config_loader'
require_relative '../../../lib/oozone/brand_installers/ipkg'

# Tests
#
class TestBrandInstallerIpkg < Minitest::Test
  def setup
    conf = Oozone::ConfigLoader.new(RES_DIR.join('test_zone_03.yaml'))
    @t = Oozone::BrandInstaller::Ipkg.new(conf)
    @execute = Spy.on(@t, :execute!)
  end

  def teardown
    @execute.unhook
  end

  def test_install!
    @t.install!
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm -z test_zone_03 install'],
                 @execute.calls.first.args)
  end

  def test_clone!
    @t.clone!('src_zone')
    assert_equal(1, @execute.calls.count)
    assert_equal(['/usr/sbin/zoneadm -z test_zone_03 clone src_zone'],
                 @execute.calls.first.args)
  end
end
