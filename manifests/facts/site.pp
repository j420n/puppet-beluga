define beluga::facts::site {
  exec {"addsite_${name}":
    command     => "echo \"${name}\" >> /etc/sites",
    unless      => "grep \"${name}\" /etc/sites",
  }
}


