# frozen_string_literal: true

require 'pathname'

ZFS = '/usr/sbin/zfs'
ZONECFG = '/usr/sbin/zonecfg'
ZONEADM = '/usr/sbin/zoneadm'
ZLOGIN = '/usr/sbin/zlogin'
PKG = '/usr/bin/pkg'
SVCADM = '/usr/sbin/svcadm'
SVCS = '/usr/bin/svcs'
ZCONF_DIR = Pathname.new('/var/tmp').freeze

# Commands which shouldn't need any special privileges
#
UNPRIVILEGED_COMMANDS = %w[compile].freeze
