class beluga::frontend_traffic_director(
  $graylog_servers = UNSET,
  $lamp_servers = [],
  $lamp_admin_servers = [],
  $solr_servers = [],
  $extra_backends = [],
  $extra_selectors = [],
  $frontend_domain = "frontend",
  $backend_domain = "backend",
  $nginx_port = 8880,
  $varnish_port = 8881
) {
  #install and configure nginx to do the front end routing of traffic

  class { 'nginx': }

  file { '/etc/nginx/conf.d/default.conf':
    ensure => absent,
  }

  nginx::resource::upstream { $lamp_servers['name']:
    ensure => present,
    members => ["${lamp_servers['host']}:${lamp_servers['upstream_port']}"]
  }

  nginx::resource::vhost {$frontend_domain:
    ensure   => present,
    listen_port => $nginx_port,
    proxy => "http://${lamp_servers['name']}",
  }

  #install and configure varnish for graylog, lamp and lamp_admin
  class { 'varnish':
    varnish_listen_port => $varnish_port
  }

  class { 'varnish::vcl':
    probes => [
      #{ name => 'health_check', url => "/health_check" }
    ],
    backends => [
      $lamp_servers,
      $lamp_admin_servers,
      $solr_servers,
      $extra_backends,
    ],
    directors => [
      { name => 'frontend', type => 'round-robin', backends => $lamp_servers['name'] }
    ],
    selectors => [
      { backend => 'solr', condition => 'req.http.host ~ "^solr."'},
      { backend => 'lamp_admin_servers', condition => 'req.http.host ~ "^admin."'},
      $extra_selectors,
      { backend => 'frontend' }
    ],
  }

}
