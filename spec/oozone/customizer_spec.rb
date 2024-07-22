#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../spec_helper'
require_relative '../../lib/oozone/customizer'
require_relative '../../lib/oozone/config_loader'

# Test the customizer class
#
class TestCustomizer < Minitest::Test
  def setup
    conf = Oozone::ConfigLoader.new(RES_DIR.join('test_zone_03.yaml'))
    @t = Oozone::Customizer.new(conf)
    @execute = Spy.on(@t, :execute!)
  end

  def test_add_facts
    refute fact_file.exist?
    @t.add_facts
    assert fact_file.exist?
    assert_equal("[general]\nzbrand=native", File.read(fact_file))
    FileUtils.rm_r('/tmp/oozone')
  end

  def test_install_packages
    @t.install_packages
    assert_equal(1, @execute.calls.count)
    assert_equal(
      ['/usr/sbin/zlogin test_zone_03 "/usr/bin/pkg install vim zsh"'],
      @execute.calls.first.args
    )
  end

  def test_run_commands
    @t.run_commands
    assert_equal(2, @execute.calls.count)
    assert_equal(
      [['/usr/sbin/zlogin test_zone_03 "/usr/bin/true"'],
       ['/usr/sbin/zlogin test_zone_03 "/usr/bin/false"']],
      @execute.calls.map(&:args)
    )
  end

  def test_run_ssh
    popen = Spy.on(Open3, :popen3)

    @t.run_ssh
    assert_equal(1, popen.calls.count)
    assert_equal(
      ["/bin/ssh -o StrictHostKeyChecking=no tester@1.2.3.4 '/bin/true'"],
      popen.calls.first.args
    )
  end

  private

  def fact_file
    Pathname.new('/tmp/oozone/zones/test02/root/etc/ansible/facts.d/zone.fact')
  end
end
