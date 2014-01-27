class beluga::apache_frontend_server(
  $apache_port = 8000,
  $domain_name = 'frontend',
  $owner = 'beluga',
  $group = 'beluga'
){

  #install and configure apache
  class { 'apache':
    default_mods        => false,
    default_confd_files => false,
    default_vhost       => false,
  }

  #create a vhost for the frontend lamp server
  apache::vhost { $domain_name:
    port          => $apache_port,
    docroot       => "/var/www/${domain_name}",
    docroot_owner => $owner,
    docroot_group => $group,
  }

}

