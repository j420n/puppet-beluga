class beluga::facts::site ($site) {
file {
  "/etc/site":
  content => $site,
}
}
