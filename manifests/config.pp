class beluga::config(
  $hiera_data,
){
  include beluga::params


  $config_dir = $::beluga::params::config_dir

}
