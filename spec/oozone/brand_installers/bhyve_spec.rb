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
  TEST_ISO_FILE = Pathname.new('/tmp/test-cloudinit.iso')

  def setup
    conf = Oozone::ConfigLoader.new(RES_DIR.join('test-bhyve.yaml'))
    @t = Oozone::BrandInstaller::Bhyve.new(conf)
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
      RES_DIR.join('cloud-init', 'common'),
      TEST_ISO_DIR
    )

    assert TEST_ISO_DIR.exist?

    TEST_ISO_DIR.children.each do |f|
      assert_equal(
        File.read(RES_DIR.join('cloud-init', 'rendered', f)),
        File.read(f)
      )
    end
    FileUtils.rm_r(TEST_ISO_DIR)
  end

  def test_create_cloudinit_iso_from_dir!
    skip unless MKISOFS.exist?

    FileUtils.rm(TEST_ISO_FILE) if TEST_ISO_FILE.exist?

    @t.create_cloudinit_img_dir(
      RES_DIR.join('cloud-init', 'common'),
      TEST_ISO_DIR
    )

    @t.create_cloudinit_iso_from_dir(TEST_ISO_DIR, TEST_ISO_FILE)

    assert TEST_ISO_FILE.exist?
    assert TEST_ISO_FILE.size > 380_927

    FileUtils.rm_r(TEST_ISO_DIR)
    FileUtils.rm(TEST_ISO_FILE)
  end
end
