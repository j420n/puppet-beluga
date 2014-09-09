class beluga::java (
  $install_jdk = $beluga::params::install_jdk
) inherits beluga::params {

  package { $beluga::params::jre_package:
    ensure  => 'present',
  }

  if ($install_jdk == true) {
    package { $beluga::params::jdk_package:
      ensure  => 'present',
    }
  }

}
