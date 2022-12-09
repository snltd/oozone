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
DLADM = '/usr/sbin/dladm'
READY_SVC = 'svc:/milestone/multi-user-server:default'
SU = '/bin/su rob -c'
SSH = '/bin/ssh'
PUPPET_SERVER = 'puppet@puppet.localnet' # comment this out to bar calls to it
PUPPET_SERVER_BIN = '/opt/ooce/bin/puppet'

# Commands which shouldn't need any special privileges
#
UNPRIVILEGED_COMMANDS = %w[compile].freeze
