class beluga::apache_frontend_server(
  $apache_port = 8000,
  $domain_name = 'frontend',
  $owner = 'beluga',
  $group = 'beluga'
){

  #install and configure apache
  class { 'apache':
    mpm_module          => 'prefork',
    default_mods        => false,
    default_confd_files => false,
    default_vhost       => false,
  }
  include apache::mod::php
  include apache::mod::rewrite

  include beluga::php

  #create a vhost for the frontend lamp server
  apache::vhost { $domain_name:
    override      => 'All',
    port          => $apache_port,
    docroot       => "/var/www/${domain_name}",
    docroot_owner => $owner,
    docroot_group => $group,
  }

}

