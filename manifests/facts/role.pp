class beluga::facts::role ($role) {
  file {
    "/etc/role":
    content => $role,
  }
}
