class beluga::apache_frontend_server(
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
  include apache::mod::wsgi

  include beluga::php

}

