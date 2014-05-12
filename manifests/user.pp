define beluga::user (
  $uid,
  $realname = '',
  $pass = '',
  $sshkeytype = '',
  $sshkey = '',
) {

  $homepath =  $beluga::params::home
  $shell    =  $beluga::params::shell

  user { $name:
    ensure            =>  'present',
    uid               =>  $uid,
    gid               =>  $title,
    shell             =>  $shell,
    home              =>  "${homepath}/${name}",
    comment           =>  $realname,
    password          =>  $pass,
    managehome        =>  true,
    require           =>  Group[$name],
  }

  group { $name:
    gid               => $uid,
  }

  file { "${homepath}/${name}":
    ensure            =>  directory,
    owner             =>  $name,
    group             =>  $name,
    mode              =>  '0755',
    require           =>  [ User[$name], Group[$name] ],
  }

}

define beluga::user::key(
  $ssh_key,
  $key_type,
){
  $homepath =  $beluga::params::home
  if ($ssh_key != '') {
    file { "${homepath}/${name}/.ssh":
      ensure            =>  directory,
      owner             =>  $name,
      group             =>  $name,
      mode              =>  '0700',
      require           =>  File["${homepath}/${name}"],
    }
    ssh_authorized_key {$name:
      ensure          => present,
      name            => $name,
      user            => $name,
      type            => $key_type,
      key             => $ssh_key,
      target          => "${homepath}/${name}/.ssh/authorized_keys",
      require         =>  File["${homepath}/${name}/.ssh"],
    }
  }
}
