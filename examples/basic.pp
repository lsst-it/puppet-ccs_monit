ensure_packages(['epel-release'])
Package['epel-release'] -> Class['ccs_monit']
include ccs_monit
