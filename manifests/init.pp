# @summary
#   Install and configure monit.
#
# @param mailhost
#   String specifying smtp server; or an array of strings.
# @param alert
#   String giving email address to receive alerts; or an array of strings.
# @param pkgurl
#   String specifying URL to fetch sources from
# @param pkgurl_user
#   String specifying username for pkgurl
# @param pkgurl_pass
#   String specifying password for pkgurl
# @param uptime
#   Monitor uptime
# @param gpfs
#   Monitor gpfs
# @param hosts
#   Monitor hosts
# @param temp
#   Monitor temp
# @param network
#   Monitor networks
#
class ccs_monit (
  Variant[String,Array[String]] $mailhost = 'localhost',
  Variant[String,Array[String]] $alert = 'root@localhost',
  String $pkgurl = 'https://example.org',
  String $pkgurl_user = 'someuser',
  String $pkgurl_pass = 'somepass',
  Boolean $uptime = true,
  Boolean $gpfs = false,
  Array[String] $hosts = [],
  Boolean $temp = false,
  Boolean $network = true,
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

  if $mailhost =~ Array {
    $mailhosts = join($mailhost, ', ')
  } else {
    $mailhosts = $mailhost
  }

  $alertfile = 'alert'
  file { "${monitd}/${alertfile}":
    ensure  => file,
    content => epp(
      "${title}/${alertfile}.epp",
      { 'mailhost' => $mailhosts, 'alerts' => $alerts }
    ),
    notify  => Service['monit'],
  }

  $config = 'config'
  file { "${monitd}/${config}":
    ensure => file,
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

  file { "${monitd}/${system}":
    ensure  => file,
    content => epp("${title}/${system}.epp", { 'uptime' => $uptime }),
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
    content => epp("${title}/${disk}.epp", { 'disks' => $disks }),
    notify  => Service['monit'],
  }

  ## Alert if a client loses gpfs.
  if $facts['native_gpfs'] == 'true' {
    $gpfse = 'gpfs-exists'
    file { "${monitd}/${gpfse}":
      ensure => file,
      source => "puppet:///modules/${title}/${gpfse}",
      notify => Service['monit'],
    }
  }

  ## Check gpfs capacity.
  if $gpfs {
    $gpfsf = 'gpfs'
    file { "${monitd}/${gpfsf}":
      ensure => file,
      source => "puppet:///modules/${title}/${gpfsf}",
      notify => Service['monit'],
    }
  }

  unless empty($hosts) {
    $hfile = 'hosts'
    file { "${monitd}/${hfile}":
      ensure  => file,
      content => epp("${title}/${hfile}.epp", { 'hosts' => $hosts }),
      notify  => Service['monit'],
    }
  }

  if $temp {
    $itemp = 'inlet-temp'
    file { "${monitd}/${itemp}":
      ensure => file,
      source => "puppet:///modules/${title}/${itemp}",
      notify => Service['monit'],
    }

    $etemp = 'monit_inlet_temp'
    file { "/usr/local/bin/${etemp}":
      ensure => file,
      source => "puppet:///modules/${title}/${etemp}",
      mode   => '0755',
      notify => Service['monit'],
    }
  }

  ## TODO try to automatically fix netspeed?
  ## We disable this on virt hosts.
  if $network and !fact('is_virtual') {
    $main_interface = fact('networking.primary')
    $nfile = 'network'
    file { "${monitd}/${nfile}":
      ensure  => file,
      content => epp(
        "${title}/${nfile}.epp",
        { 'interface' => $main_interface }
      ),
      notify  => Service['monit'],
    }
  }

  $netspeed = 'monit_netspeed'
  file { "/usr/local/bin/${netspeed}":
    ensure => file,
    source => "puppet:///modules/${title}/${netspeed}",
    mode   => '0755',
  }

  if fact('has_dellperc') {
    $hwraidf = 'hwraid'
    file { "${monitd}/${hwraidf}":
      ensure => file,
      source => "puppet:///modules/${title}/${hwraidf}",
      notify => Service['monit'],
    }

    ## Needs the raid utility (eg perccli64) to be installed.
    $hexe = 'monit_hwraid'
    file { "/usr/local/bin/${hexe}":
      ensure => file,
      source => "puppet:///modules/${title}/${hexe}",
      mode   => '0755',
    }
  }

  service { 'monit':
    ensure => running,
    enable => true,
  }
}
