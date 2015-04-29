class beluga::php(
  $memory_limit = $beluga::params::php_memory_limit,
) inherits beluga::params {

  #you can use a global package parameter
  Package { ensure => "installed" }

  $packages = ["$beluga::params::php_package","$beluga::params::php_gd_package","$beluga::params::php_postgres_package"]

  package{$packages:}

  class {'mysql::bindings':
    php_enable         => true,
  }

  file {$beluga::params::php_ini:
    content => template('beluga/php.ini.erb'),
    require => Class['apache_frontend_server'],
  }
}
