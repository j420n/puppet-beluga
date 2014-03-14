class beluga::install(){
  #we depend on hiera and hiera-eyaml for encrypting the password properties.
  package { 'hiera':
    ensure   => 'installed',
    provider => 'gem',
  }

  package { 'hiera-eyaml':
    ensure   => 'installed',
    provider => 'gem',
  }

  package { 'unzip': }
}
