class beluga::params {
  case $::osfamily {
    'Debian': {
      $hiera_data_dir  = '/etc/beluga'
      $hiera_source_dir = 'puppet:///modules/beluga/hieradata'
      $owner = 'root'
      $group = 'root'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
