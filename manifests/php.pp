class beluga::php inherits beluga::params {
  package { $beluga::params::php_package:
    ensure => 'installed'
  }
  class {'mysql::bindings':
    php_enable         => true,
  }
  package { $beluga::params::php_gd_package:
    ensure   => 'installed',
  }
  package { $beluga::params::php_postrges_package:
    ensure  => 'installed',
  }
}
