class beluga::php(
  $memory_limit = $beluga::params::php_memory_limit,
) inherits beluga::params {

  #you can use a global package parameter
  Package { ensure => "installed" }
  
  case $::osfamily {
    'RedHat': {

    }
    'Debian': {
      package { $beluga::params::php_common_package: } ->
      package { $beluga::params::php_gd_package: } ->
      package { $beluga::params::php_cli_package: } ->
      package { $beluga::params::php_cgi_package: } ->
      package { $beluga::params::php_curl_package: } ->
      package { $beluga::params::php_mcrypt_package: } ->
      package { $beluga::params::php_mysql_package: } ->
      package { $beluga::params::php_postgres_package: }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  class {'mysql::bindings':
    php_enable         => true,
  }
  
  file {$beluga::params::php_ini:
    content => template('beluga/php.ini.erb'),
    require => Class['apache_frontend_server'],
  }
}
