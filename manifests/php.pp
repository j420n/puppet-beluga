class beluga::php(
  $memory_limit = $beluga::params::php_memory_limit,
) inherits beluga::params {
  package { $beluga::params::php_package:
    ensure => 'installed'
  }
  class {'mysql::bindings':
    php_enable         => true,
  }
  package { $beluga::params::php_gd_package:
    ensure   => 'installed',
  }
  package { $beluga::params::php_postgres_package:
    ensure  => 'installed',
  }
  file {$beluga::params::php_ini:
    content => template('beluga/php.ini.erb'),
    require => Class['apache_frontend_server'],
  }
}
