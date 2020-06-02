## @summary
##   Install and configure monit.
##
## @param mailhost
##   String specifying smtp server
## @param alert
##   String giving email address to receive alerts; or an array of strings.

class ccs_monit (
  String $mailhost = 'localhost',
  Variant[String,Array[String]] $alert = 'root@localhost',
) {

  ensure_packages(['monit', 'freeipmi'])

  ## Not sure if monit creates this...
  file { '/var/monit':
    ensure => directory,
  }


  ## Change check interval from 30s to 5m.
  ## TODO? add "read-only" to the allow line?
  file_line { 'Change monit interval':
    path   => '/etc/monitrc',
    match  => '^set daemon',
    line   => 'set daemon  300  # check services at 300 seconds intervals',
    notify => Service['monit'],
  }


  $monitd = '/etc/monit.d'

  if $alert =~ String {
    $alerts = [$alert]
  } else {
    $alerts = $alert
  }

  $alertfile = 'alert'
  file { "${monitd}/${alertfile}":
    ensure  => file,
    content => epp(
      "${title}/${alertfile}.epp",
      {'mailhost' => $mailhost, 'alerts' => $alerts}
    ),
    notify  => Service['monit'],
  }


  $config = 'config'
  file { "${monitd}/${config}":
    ensure => present,
    source => "puppet:///modules/${title}/${config}",
    notify => Service['monit'],
  }


  ## system:
  ## Note that the use of "per core" requires monit >= 5.26.
  ## As of 2019/09, the epel7 version is 5.25.
  ## This requires us to install a newer version in /usr/local/bin,
  ## and modify the service file, but it does mean the config file can
  ## be identical for all hosts.
  ## swap warning is not very useful, since Linux doesn't usually free swap.
  ## Maybe it should just be removed?
  ##
  ## We are using uptime to detect reboots. It also alerts on success.
  ## This could be suppressed with:
  ##  else if succeeded exec "/bin/false"
  ## but that means uptime is always in failed state.

  $system = 'system'

  $uptime = lookup('ccs_monit::uptime', Boolean, undef, true)

  file { "${monitd}/${system}":
    ensure  => present,
    content => epp("${title}/${system}.epp", {'uptime' => $uptime}),
    notify  => Service['monit'],
  }


  ## Ignoring: /boot, and in older slac installs: /scswork, /usr/vice/cache.
  ## vi do not have separate /tmp.
  ## dc nodes have /data.
  ## Older installs have separate /opt /scratch /var.
  ## Newer ones have /home instead.
  ## TODO loop over mount points instead?
  ## Can also do IO rates.
  $disks = {
    'root'    => '/',
    'tmp'     => '/tmp',
    'home'    => '/home',
    'data'    => '/data',
    'opt'     => '/opt',
    'var'     => '/var',
    'scratch' => '/scratch',
    'lsst-ir2db01' => '/lsst-ir2db01',
  }.filter|$key,$value| { $facts['mountpoints'][$value] }

  $disk = 'disks'
  file { "${monitd}/${disk}":
    ensure  => file,
    content => epp("${title}/${disk}.epp", {'disks' => $disks}),
    notify  => Service['monit'],
  }


  ## Alert if a client loses gpfs.
  if $facts['native_gpfs'] == 'true' {
    $gpfse = 'gpfs-exists'
    file { "${monitd}/${gpfse}":
      ensure => present,
      source => "puppet:///modules/${title}/${gpfse}",
      notify => Service['monit'],
    }
  }


  $gpfs = lookup('ccs_monit::gpfs', Boolean, undef, false)

  ## Check gpfs capacity.
  if $gpfs {
    $gpfsf = 'gpfs'
    file { "${monitd}/${gpfsf}":
      ensure => present,
      source => "puppet:///modules/${title}/${gpfsf}",
      notify => Service['monit'],
    }
  }


  $hosts = lookup('ccs_monit::ping_hosts', Array[String], undef, [])

  unless empty($hosts) {
    $hfile = 'hosts'
    file { "${monitd}/${hfile}":
      ensure  => file,
      content => epp("${title}/${hfile}.epp", {'hosts' => $hosts}),
      notify  => Service['monit'],
    }
  }


  $temp = lookup('ccs_monit::temp', Boolean, undef, false)

  if $temp {
    $itemp = 'inlet-temp'
    file { "${monitd}/${itemp}":
      ensure => present,
      source => "puppet:///modules/${title}/${itemp}",
      notify => Service['monit'],
    }

    $etemp = 'monit_inlet_temp'
    file { "/usr/local/bin/${etemp}":
      ensure => present,
      source => "puppet:///modules/${title}/${etemp}",
      mode   => '0755',
      notify => Service['monit'],
    }
  }


  ## TODO try to automatically fix netspeed?
  ## Hiera disables this on virt hosts.
  $network = lookup('ccs_monit::network', Boolean, undef, true)

  if $network {
    $main_interface = $profile::ccs::facts::main_interface
    $nfile = 'network'
    file { "${monitd}/${nfile}":
      ensure  => file,
      content => epp(
        "${title}/${nfile}.epp",
        {'interface' => $main_interface}
      ),
      notify  => Service['monit'],
    }
  }


  $netspeed = 'monit_netspeed'
  file { "/usr/local/bin/${netspeed}":
    ensure => present,
    source => "puppet:///modules/${title}/${netspeed}",
    mode   => '0755',
  }


  $ccs_pkgarchive = lookup('ccs_pkgarchive',String)
  $hwraid = lookup('ccs_monit::hwraid', Boolean, undef, true)

  if $hwraid {

    $hwraidf = 'hwraid'
    file { "${monitd}/${hwraidf}":
      ensure => present,
      source => "puppet:///modules/${title}/${hwraidf}",
      notify => Service['monit'],
    }

    $perc = 'perccli64'
    $percfile = "/var/tmp/${perc}"
    archive { $percfile:
      ensure => present,
      source => "${ccs_pkgarchive}/${perc}",
    }
    file { "/usr/local/bin/${perc}":
      ensure => present,
      source => $percfile,
      mode   => '0755',
    }

    ## Needs the raid utility (eg perccli64) to be installed.
    $hexe = 'monit_hwraid'
    file { "/usr/local/bin/${hexe}":
      ensure => present,
      source => "puppet:///modules/${title}/${hexe}",
      mode   => '0755',
    }
  }


  $service = '/etc/systemd/system/monit.service'
  exec { 'Create monit.service':
    path    => ['/usr/bin'],
    command => "sh -c \"sed 's|/usr/bin/monit|/usr/local/bin/monit|g' /usr/lib/systemd/system/monit.service > ${service}\"",
    creates => $service,
  }


  ## Note that we configure this monit with --prefix=/usr so that
  ## it consults /etc/monitrc, and install just the binary by hand.
  $exe = 'monit'
  $exefile = "/var/tmp/${exe}"

  archive { $exefile:
    ensure => present,
    source => "${ccs_pkgarchive}/${exe}",
  }

  ## archive does not support mode.
  file { "/usr/local/bin/${exe}":
    ensure => present,
    source => $exefile,
    mode   => '0755',
  }


  service { 'monit':
    ensure => running,
    enable => true,
  }


}
