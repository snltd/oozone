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

  def test_test
    assert_equal(RES_DIR.to_s, "/some/path")
  end

  def _test_01_zone_file_is_created_correctly
    obj = Oozone::ConfigLoader.new(RES_DIR.join('test_zone_01.yaml'))
    assert_equal(contents_of('test_zone_01.zone'), obj.config)
  end

  def _test_01_metadata
    m = Oozone::ConfigLoader.new(RES_DIR.join('test_zone_01.yaml')).metadata
    assert_instance_of(Hash, m)
    assert_equal('test_zone_01', m[:zone_name])
    assert_equal({ domain: 'localnet',
                   nameserver: %w[192.168.1.26 192.168.1.1] }, m[:dns])
    assert_equal({ role: 'wavefront-proxy',
                   environment: 'lab' }, m[:facts])
    assert_equal(%w[ooce/runtime/ruby-26], m[:packages])
    assert_equal(['/opt/ooce/bin/gem install puppet',
                  '/opt/ooce/bin/puppet agent -t'], m[:run_cmd])
    assert_equal({ '/etc/release': '/var/tmp/etc/release',
                   '/etc/passwd': '/passwd' }, m[:upload])
    assert_equal(Pathname.new('/zones/wavefront/root'), m[:root])
  end

  def _test_02_zone_file_is_created_correctly
    obj = Oozone::ConfigLoader.new(RES_DIR.join('test_zone_02.yaml'))
    assert_equal(contents_of('test_zone_02.zone'), obj.config)
  end

  def _test_02_metadata
    m = Oozone::ConfigLoader.new(RES_DIR.join('test_zone_02.yaml')).metadata
    assert_instance_of(Hash, m)
    assert_equal('test_zone_02', m[:zone_name])
    assert_equal(Pathname.new('/zones/test02/root'), m[:root])
    refute m.key?(:dns)
    refute m.key?(:facts)
    refute m.key?(:packages)
    refute m.key?(:run_cmd)
    refute m.key?(:upload)
  end

  def _test_write_config
    File.stubs(:write)
        .with(Pathname.new('/var/tmp/test_zone_01.zone'),
              contents_of('test_zone_01.zone'))
        .returns(true)

    assert Oozone::ConfigLoader.new(
      RES_DIR.join('test_zone_01.yaml')
    ).write_config
  end

  private

  def contents_of(zone_file)
    File.read(RES_DIR.join(zone_file))
  end
end
