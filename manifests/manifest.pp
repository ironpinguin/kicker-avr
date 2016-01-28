node default {

  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  }

  if $::bootstrapped == undef {
    exec { 'apt-update':
      command => 'apt-get update',
      unless  => 'which avr-gcc',
      before  => Package['avr-libc', 'binutils-avr']
    } ->
    file { ['/etc/facter', '/etc/facter/facts.d/']:
      ensure  => directory,
      recurse => true,
    } ->
    file { '/etc/facter/facts.d/bootstrapped.txt':
      ensure  => file,
      content => "bootstrapped=true\n",
    }

    augeas { 'remove-deprecated-templatedir-parameter':
      context => '/files/etc/puppet/puppet.conf/main',
      changes => [
        'rm templatedir',
      ],
    }
  }

  package { ['ruby', 'git', 'make', 'cmake', 'automake', 'autoconf']:
    ensure        => installed,
    allow_virtual => true,
  } ->
  package { ['avr-libc', 'avra', 'avrdude', 'avrp', 'avrprog', 'binutils-avr', 'gcc-avr', 'gdb-avr']:
    ensure        => installed,
    allow_virtual => true,
  } ->
  package { ['libelf-dev', 'freeglut3-dev', 'xauth', 'pkg-config', 'strace', 'gtkwave']:
    ensure        => installed,
    allow_virtual => true,
  } ->
  exec { 'simavr install':
    command => 'tar -xz -C / -f /vagrant/simavr.tgz',
    unless  => 'which simavr',
  } -> 
  exec { 'update ldconfig':
    command => 'ldconfig',
  } 
}
