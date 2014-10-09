class beluga::wget (
  $wget_package = $beluga::params::wget_package
) inherits beluga::params {
  package { $wget_package:
    ensure  => 'present',
  }
}
