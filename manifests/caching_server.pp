class beluga::caching_server(
  $source_dir = 'UNSET',
  $port = '8081',
  $control_port = '8005'
){

  class { "tomcat":
    http_port => 8081,
  }

  class { 'solr':
    source_dir => $source_dir,
    source_dir_purge => true,
  }

}


