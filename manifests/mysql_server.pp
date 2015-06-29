class beluga::mysql_server (
  $admin_password = "default",
){
  class { '::mysql::server':
    root_password    => $admin_password,
    #If mysql override options are set here then we cant set them with hiera.
    #override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
}
