class beluga::java (
  $install_jdk = $beluga::params::install_jdk
) inherits beluga::params {

  if ($install_jdk == true) {
    package { $beluga::params::jdk_package:
      ensure  => 'present',
    }
  }

}
