class beluga::mysql_server (
  $admin_password = "UNSET",
){
  if ("UNSET" == $admin_password){
    $admin_password = hiera("beluga::mysql_server::admin_password")
  }
  notify {"Installing mysql server with root password of: $admin_password":
  }

  class { '::mysql::server':
    root_password    => $admin_password,
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
}
