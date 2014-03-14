class beluga::params {
  case $::osfamily {
    'Debian': {
      $hiera_data_dir  = '/etc/beluga'
      $hiera_source_dir = 'puppet:///modules/beluga/hieradata'
      $owner = 'root'
      $group = 'root'
      $unzip_package = 'unzip'
      $php_gd_package = 'php5-gd'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
