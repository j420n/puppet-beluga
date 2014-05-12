class beluga::params {
  case $::osfamily {
    'Debian': {
      $hiera_data_dir  = '/etc/beluga'
      $hiera_source_dir = 'puppet:///modules/beluga/hieradata'
      $owner = 'root'
      $group = 'root'
      $unzip_package = 'unzip'
      $php_gd_package = 'php5-gd'
      $php_package = 'php5-cli'
      $php_postrges_package = 'php5-pgsql'
      $default_ruby_version = 'ruby-1.9'
      $home = '/home;'
      $shell = '/bin/bash'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
