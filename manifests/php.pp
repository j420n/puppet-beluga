class beluga::php (){
  package { $beluga::params::php_package:
    ensure => 'installed'
  }
  class {'mysql::bindings':
    php_enable         => true,
  }
  package { $beluga::params::php_gd_package:
    ensure   => 'installed',
  }
}
