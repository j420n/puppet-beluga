class beluga::frontend_traffic_director(
  $graylog_servers = $beluga::params::graylog_servers,
  $lamp_servers = $beluga::params::lamp_servers,
  $lamp_admin_servers =  $beluga::params::lamp_admin_servers,
  $solr_servers =  $beluga::params::solr_servers,
  $extra_backends = [],
  $extra_selectors = [],
  $frontend_domain = "frontend",
  $backend_domain = "backend",
  $nginx_port = 8880,
  $varnish_port = 8881
) {
  #install and configure nginx to do the front end routing of traffic

  include 'nginx'

  $ret = inline_template("<%= lamp_servers.each do |lamp_server| ${lamp_server['host']}:${lamp_server['upstream_port']},")
  notify{$ret:}

  nginx::resource::upstream {$lamp_servers:
    ensure => present,
    #members => inline_template("<%= lamp_servers.each do |lamp_server| \"${lamp_server['host']}:${lamp_server['upstream_port']},\"%>").split
  }

  nginx::resource::vhost {$frontend_domain:
    ensure   => present,
    listen_port => $nginx_port,
    pproxy => "http://${$frontend_domain}",
  }

  #install and configure varnish for graylog, lamp and lamp_admin
  class { 'varnish':
    varnish_listen_port => $varnish_port
  }

  $all_backends = push([$lamp_servers, $lamp_admin_servers, $solr_servers], $extra_backends)
  $selectors1 = [
    { backend => 'solr', condition => 'req.http.host ~ "^solr."'},
    { backend => 'lamp_admin_servers', condition => 'req.http.host ~ "^admin."'}]
  $selectors2 = push($selectors1, $extra_selectors)
  $all_selectors = push($selectors2, [ { backend => 'frontend' }])
  class { 'varnish::vcl':
    probes => [
      #{ name => 'health_check', url => "/health_check" }
    ],
    backends => $all_backends,
    directors => [
      { name => 'frontend', type => 'round-robin', backends => $lamp_servers['name'] }
    ],
    selectors => $all_selectors,
  }

}
