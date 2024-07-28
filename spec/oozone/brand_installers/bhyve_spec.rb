#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/oozone/config_loader'
require_relative '../../../lib/oozone/brand_installers/bhyve'

# Tests
#
class TestBrandInstallerBhyve < Minitest::Test
  TEST_ISO_DIR = Pathname.new('/tmp/test-iso-build-dir').freeze
  TEST_RENDER = Pathname.new('/tmp/test-render').freeze

  def setup
    conf = Oozone::ConfigLoader.new(RES_DIR.join('test-bhyve.yaml'))
    @t = Oozone::BrandInstaller::Bhyve.new(conf)
    # @execute = Spy.on(@t, :execute!)
    # @ci_dir = Pathname.new('/tmp').join('test-bhyve')
    FileUtils.rm(TEST_RENDER) if TEST_RENDER.exist?
  end

  def test_fresh_cloudinit_iso_dir_not_exists
    FileUtils.rm_r(TEST_ISO_DIR) if TEST_ISO_DIR.exist?
    refute TEST_ISO_DIR.exist?
    @t.fresh_cloudinit_iso_dir(TEST_ISO_DIR)
    assert TEST_ISO_DIR.exist?
    FileUtils.rm_r(TEST_ISO_DIR)
  end

  def test_fresh_cloudinit_iso_dir_exists
    test_file = TEST_ISO_DIR.join('tester')
    FileUtils.mkdir_p(TEST_ISO_DIR)
    FileUtils.copy_file(__FILE__, test_file)
    assert test_file.exist?
    @t.fresh_cloudinit_iso_dir(TEST_ISO_DIR)
    assert TEST_ISO_DIR.exist?
    refute test_file.exist?
    FileUtils.rm_r(TEST_ISO_DIR)
  end

  def test_cloudinit_src_dir
    assert_nil @t.cloudinit_src_dir(Pathname.new('no-such'), 'no-such-zone')
    assert_equal(
      RES_DIR.join('cloud-init', 'test-bhyve'),
      @t.cloudinit_src_dir(RES_DIR.join('cloud-init'), 'test-bhyve')
    )
    assert_equal(
      RES_DIR.join('cloud-init', 'common'),
      @t.cloudinit_src_dir(RES_DIR.join('cloud-init'), 'nozone')
    )
  end

  def test_create_cloudinit_img_dir
    FileUtils.rm_r(TEST_ISO_DIR) if TEST_ISO_DIR.exist?
    refute TEST_ISO_DIR.exist?

    @t.create_cloudinit_img_dir(
      'test-bhyve', 
      RES_DIR.join('cloud-init', 'common'),
      TEST_ISO_DIR, 
    )

    assert TEST_ISO_DIR.exist?
    FileUtils.rm_r(TEST_ISO_DIR)
  end

  def test_render_cloudinit_template
    %w[meta-data network-config user-data].each do |f|
      @t.render_cloudinit_template(
        RES_DIR.join('cloud-init', 'common', f),
        TEST_RENDER
      )

      assert_equal(
        File.read(RES_DIR.join('cloud-init', 'rendered', f)),
        File.read(TEST_RENDER)
      )
    end
  end

end
