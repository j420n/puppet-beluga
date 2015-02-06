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

}
