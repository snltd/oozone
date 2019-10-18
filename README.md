# oozone

Simple zone management for OmniOS.

Written purely to scratch my own itch. I'm making no attempt at compatability
with other Illumos distributions, or Solaris.

## Zone Defintions

Zones are defined in YAML files. There's a simple and (hopefully) obvious
mapping from YAML to a zone config file. For instance:

```yaml
---
brand: sparse
zonepath: /zones/example
autoboot: true
fs:
  - dir: /home
    special: /home
    type: lofs
  - dir: /storage
    special: /storage
    type: lofs
net:
  - physical: test0
    'global-nic': auto
    'allowed-address': 192.168.1.38/24
    'defrouter': 192.168.1.1
```

Compiles to:

```
create -b
set brand=sparse
set zonepath=/zones/example
set autoboot=true
add fs
set dir=/home
set special=/home
set type=lofs
end
add fs
set dir=/storage
set special=/storage
set type=lofs
end
add net
set physical=test0
set global-nic=auto
set allowed-address=192.168.1.38/24
set defrouter=192.168.1.1
end
```

You can add extra information to the YAML file. The following extras are
supported, and they happen in this order.

### DNS Configuration

Add a block like this to your zone definition. All keys are optional. Things
like `sortlist` will work if you add the list as an array.

```yaml
dns:
  domain: localnet
  search: localnet
  nameserver:
    - 192.168.1.26
    - 192.168.1.1
```

### Packages

You can ask `oozone` to install packages once the zone is created. Add the
`packages` is the key with a list of FMRIs.

```yaml
packages:
  - 'ooce/runtime/ruby-26'
```

### Puppet Integration

If you use Puppet, like I do, you can add a `facts` hash. The facts will end
up in `/etc/factor/facts.d/basic_facts.txt`. If this file is created, `oozone`
adds in a `zbrand` fact, which I need for my stuff. (So far as I can tell, you
can't get the *real* brand of a zone from inside it. `pkgsrc`, `sparse`,
`ipkg` etc all report as `native`.)

```yaml
facts:
  role: wavefront-proxy
  environment: lab
```

### Upload Files

The `upload` key lets you give a list of files and/or directories which will
be copied into the zone. The key is the source file in the global zone, the
value is the destination inside the zone.

```yaml
upload:
  /etc/release: /var/tmp/etc/release
  /etc/passwd: /passwd
```

### Running Commands

Use the `run_cmd` key to add a list of commands you want to run in the zone
once installation is complete. The commands are run via `zlogin(1)`, so their
context is inside the zone.

```yaml
run_cmd:
  - '/opt/ooce/bin/gem install puppet -v 5.5.0 --no-document --bindir=/opt/ooce/bin'
  - '/opt/ooce/bin/puppet agent -t'
```

## Commands

`oozone` does not perform any privilege escalation on your behalf. So, you
must run it as root or with a profile which allows zone creation and arbitrary
file writing. Running with a non-zero EUID will issue a warning and give you
three seconds to hit CTRL-C and abort.

### Create

```
oozone create [-F] <file>...
```

Turn each given file into zones. If a zone exists, it is skipped, unless `-F`
is given, in which case the zone is destroyed and rebuilt.

### Clone

```
oozone clone [-F] <zone> <file>...
```

Creates a zone described in each `<file>`, based on a clone of `<zone>`.
Normal rules apply: `<zone>` must not be running, and you can only clone the
same brand. `oozone` doesn't bother catching those kinds of errors, so you'll
just see the stderr of `zoneadm` or `zonecfg`.

### Destroy

```
oozone destroy <zone>...
```

Destroys all given zones. It won't check whether you're sure, so make certain
you are.

### Compile

```
oozone compile <file>...
```

Creates files suitable for `zonecfg(1m)` in `/var/tmp`.  Doesn't require any
special privileges.

### Customize

```
oozone customize <file>...
```

Re-reads the given zone definitions and enacts all the zone configuration
steps. DNS, facts, uploads etc. Not in any way guaranteed to be idempotent,
and almost certainly not of use to anyone not extending `oozone`.
