class beluga::postgresql_server (
  $admin_password = "UNSET",
){
  if ("UNSET" == $admin_password){
    $admin_pass = hiera("beluga::postgress_server::admin_password")
  } else {
    $admin_pass = $admin_password
  }
  notify {"Installing postgresql with a password of: $admin_pass": }

  class { 'postgresql::server':
    postgres_password          => $admin_pass,
  }
}
