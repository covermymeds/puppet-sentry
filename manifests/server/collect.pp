# == Class: sentry::server:collect
#
# === Parameters
#
#  None
#
# === Actions:
#
#  Collects Sentry Project Resources add to 
#  the Sentry server
#
# === Authors:
#
#  Dan Sajner <dsajner@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class sentry::server::collect (
  $tag = undef,
) {

  # Collect all the Sentry Projects
  ::Sentry::Source::Project <<| tag == $tag |>>

}
