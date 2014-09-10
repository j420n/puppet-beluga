class beluga::caching_server(
  $source_dir = 'UNSET',
  $port = '8081',
  $control_port = '8005'
){

  class { "tomcat":
    http_port => $port,
  }

  class { 'solr':
    source_dir => $source_dir,
    source_dir_purge => true,
  }

  class {'memcached':
    port    => 11211,
    memory  => 64,
  }

  memcached::config {'instance0':
    port    => 11212,
    memory  => 64,
    listen => false,
  }

  memcached::config {'instance1':
    port    => 11212,
    memory  => 64,
  }
}


