class beluga::mysql_server (
  $admin_password = hiera("beluga::mysql_server::admin_password", undef),
){
  class { '::mysql::server':
    root_password    => $admin_password,
    #If mysql override options are set here then we cant set them with hiera. see files/hieradata/common.yaml
    #override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
}

