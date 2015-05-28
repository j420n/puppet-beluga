class beluga::docker(
  $url = hiera('beluga::docker::url', undef),
){
  notify{'Installing docker.io':}
  exec { 'install-docker':
    command   => "/usr/bin/curl -ssL ${url}/ | sh",
    onlyif    => "/usr/bin/test ! -f /usr/bin/docker",
  }
}