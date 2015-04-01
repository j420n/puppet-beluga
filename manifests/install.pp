class beluga::install(){
  #we depend on hiera and hiera-eyaml for encrypting the password properties.
  package { 'hiera':
    ensure   => 'installed',
    provider => 'gem',
  }

  package { 'hiera-eyaml':
    ensure   => 'installed',
    provider => 'gem',
  }

  package { $beluga::params::unzip_package:
    ensure   => 'installed',
  }

  case $::osfamily {
    'RedHat': {

    }
    'Debian': {

       exec { "apt-update":
         command => "/usr/bin/apt-get update"
       }

       Exec["apt-update"] -> Package <| |>

       package { 'lsb-release':
         ensure => installed,
       }

    }
    default: {
       fail("${::operatingsystem} not supported")
    }
  }



}
