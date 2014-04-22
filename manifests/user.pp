define beluga::user (
  $uid,
  $realname,
  $pass,
  $sshkeytype,
  $sshkey,
) {

  $homepath =  $beluga::params::home
  $shell    =  $beluga::params::shell

  user { $user:
    ensure            =>  'present',
    uid               =>  $uid,
    gid               =>  $title,
    shell             =>  $shell,
    home              =>  "${home}/${user}",
    comment           =>  $realname,
    password          =>  $pass,
    managehome        =>  true,
    require           =>  Group[$name],
  }

  group { $title:
    gid               => $uid,
  }

  file { "${home}/${user}":
    ensure            =>  directory,
    owner             =>  $user,
    group             =>  $user,
    mode              =>  '0750',
    require           =>  [ User[$user], Group[$user] ],
  }

  file { "${home}/${user}/.ssh":
    ensure            =>  directory,
    owner             =>  $user,
    group             =>  $user,
    mode              =>  '0700',
    require           =>  File["${home}/${user}"],
  }

  if ($sshkey != '') {
    ssh_authorized_key {$user:
      ensure          => present,
      name            => $user,
      user            => $user,
      type            => $sshkeytype,
      key             => $sshkey,
    }
  }
}
