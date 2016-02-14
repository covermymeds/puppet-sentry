# == Define: sentry::source::export
#
# A defined type to wrap the export of a Sentry project
#
# === Paramaters
#
# [*language*]: 
#   the Sentry language to use
#
# [*organization*]:
#   the organization to which the project is assigned
#
# [*team*]:
#   the team to which this project is assigned
#
# [*env*]
#   the tag to apply
#
# === Notes
#
# The language you suppy here is **not** validated.  Be sure to use
# a value that is supported by Sentry.
#
# === Authors
#
# Dan Sajner <dsajner@covermymeds.com>
# Scott Merrill <smerrill@covermymeds.com>
# Bill Schwanitz <bschwanitz@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds
#
define sentry::source::export (
  $language     = 'Other',
  $organization = $::sentry::organization,
  $team         = $::sentry::team,
  $env          = undef,
) {

  # Allow for a custom fact named appname_lang.
  # If this fact exists, use its value for the language
  # for this project.
  # NOTE: this custom fact is **not** supplied with this
  # module.  You're on your own to create and use it.
  $override_language = getvar("${name}_lang")
  if $override_language {
    $real_lang = $override_language
  } else {
    $real_lang = $language
  }

  if (! $organization) or ($organization == '') {
    # an empty string or "undef" was passed. Use the default
    # organization.
    $o = $::sentry::organization
  } else {
    $o = $organization
  }

  if (! $team) or ($team == '') {
    # an empty string or "undef" was passed. Use the default team.
    $t = $::sentry::team
  } else {
    $t = $team
  }

  # Export a Sentry project. Resource has the hostname so its unique.
  @@sentry::source::project { "${name}-${::hostname}":
    organization => $o,
    project      => $name,
    platform     => $real_lang,
    team         => $t,
    tag          => $env,
  }

}
