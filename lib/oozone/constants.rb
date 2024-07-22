# frozen_string_literal: true

require 'pathname'

ZFS = Pathname.new('/usr/sbin/zfs')
ZONECFG = Pathname.new('/usr/sbin/zonecfg')
ZONEADM = Pathname.new('/usr/sbin/zoneadm')
ZLOGIN = Pathname.new('/usr/sbin/zlogin')
PKG = Pathname.new('/usr/bin/pkg')
SVCADM = Pathname.new('/usr/sbin/svcadm')
SVCS = Pathname.new('/usr/bin/svcs')
ZCONF_DIR = Pathname.new('/var/tmp').freeze
DLADM = Pathname.new('/usr/sbin/dladm')
SSH = Pathname.new('/bin/ssh')
PUPPET_SERVER = 'puppet@puppet.localnet' # comment this out to bar calls to it
PUPPET_SERVER_BIN = Pathname.new('/opt/ooce/bin/puppet')
READY_SVC = 'svc:/milestone/multi-user-server:default'
SU = '/bin/su rob -c'

VOLUME_ROOT_DS = 'rpool/zones/bhyve'

# Commands which shouldn't need any special privileges
#
UNPRIVILEGED_COMMANDS = %w[compile ls].freeze
