#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/oozone/vnic_manager'

MULTI_HOMED_ZONE = %Q(
---
net:
  - physical: net0
    'global-nic': rge0
    allowed-address: 192.168.1.39/24
    'defrouter': 192.168.1.1
  - physical: net1
    'global-nic': rge1
    allowed-address: 10.0.0.1/8
)

SHARED_IP_ZONE = %Q(
---
ip-type: shared
)

# Test the VNIC manager
#
class VnicManagerTest < MiniTest::Test
  attr_reader :zone_01, :shared_ip_zone, :multihomed_zone

  def setup
    @zone_01 = Oozone::VnicManager.new(
      'test-zone-01', load_config(IO.read(RES_DIR + 'test_zone_01.yaml'))
    )
    @shared_ip_zone = Oozone::VnicManager.new('sip-zone',
                                              load_config(SHARED_IP_ZONE))
    @multihomed_zone = Oozone::VnicManager.new('mh-zone',
                                               load_config(MULTI_HOMED_ZONE))
  end

  def test_is_shared_ip?
    assert shared_ip_zone.shared_ip?
  end

  def test_is_not_shared_ip?
    refute zone_01.shared_ip?
  end

  def test_vnic_map
    zone_01.stubs(:dladm_info).returns("net0\nnet1\n")
    assert_equal({'net0' => 'net0_test_zone_01_test0'}, zone_01.vnic_map)
    assert_equal({'rge0' => 'rge0_mh_zone_net0',
                  'rge1' => 'rge1_mh_zone_net1'}, multihomed_zone.vnic_map)
    assert_equal({}, shared_ip_zone.vnic_map)
  end

  def load_config(input)
    YAML.safe_load(input, symbolize_names: true)
  end
end
