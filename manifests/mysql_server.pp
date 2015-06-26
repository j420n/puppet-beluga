class beluga::mysql_server (
  $admin_password = "UNSET",
){
  if ("UNSET" == $admin_password){
    $tmp_admin_password = hiera("beluga::mysql_server::admin_password")
  } else {
    $tmp_admin_password = $admin_password
  }

  class { '::mysql::server':
    root_password    => $admin_password,
    #If mysql override options are set here then we cant set them with hiera.
    #override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
}
