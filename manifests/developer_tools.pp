class beluga::developer_tools(
  $install_grunt = true,
){

  if ($install_grunt){
    exec { 'install-grunt':
      path      => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/bin'],
      command   => "/usr/local/node/node-default/bin/npm  install -g grunt-cli",
      require   => Class['nodejs'],
    }
  }

}
