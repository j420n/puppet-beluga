class beluga() inherits beluga::params {

  class { 'beluga::install': } ->
  class { 'beluga::config':
    hiera_data => $hiera_data,
  } ->
  #~>
  #Class['beluga::service'] ->
  Class['beluga']
}
