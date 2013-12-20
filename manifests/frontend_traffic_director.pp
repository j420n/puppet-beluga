class beluga::frontend_traffic_director(
  $graylog,
  $lamp_servers,
  $lamp_admin_servers
) {
  //create varnish backend for greylog, lamp and lam_admin

  class { 'varnish::vcl':
    probes => [
      { name => 'health_check', url => "/health_check" },
    ],
    backends => [
      { name => 'server1', host => '192.168.1.1', port => '80', probe => 'health_check' },
      { name => 'server2', host => '192.168.1.2', port => '80', probe => 'health_check' },
    ],
    directors => [
      { name => 'cluster', type => 'round-robin', backends => [ 'server1', 'server2' ] }
    ],
    selectors => [
      { backend => 'cluster' },
    ],
  }

}
