# == Define: sentry::source::project
#
# This is a defined type that creates a Sentry project if it 
# doesn't exist.
#
# === Parameters
# organization: the organization to which this project is assigned
# project: the name of the project
# platform: the language used by this project
# path: the virtualenv path to use for Sentry
# team: the team to which the project is assigned
#
# === Authors
#
# Dan Sajner <dsajner@covermymeds.com>
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds
#
define sentry::source::project (
  $organization,
  $project,
  $platform,
  $team,
  $path = $::sentry::path,
) {

  # create exactly one project, regardless of how many app
  # servers might be running the corresponding application.
  #
  # We use `if ! defined` here because we don't want catalog
  # compilation to fail in the event that a project's platform
  # changes for any reason. Such a change might be due to an
  # unexpected error, or by intentional operator decision.
  #

  if ($organization == $::sentry::organization) and ($team == $::sentry::team) {
    # if this project is being created in the default team, just use
    # the project name for the Exec resource and the DSN cache file.
    $p = $project
  } else {
    # if this project is being created in a new team, create a namespace
    # using "team/project" format. This will be used for the Exec and
    # the DSN cache file.  Be sure the uriescape the resulting string!
    $p = uriescape("${organization}/${team}/${project}")
  }

  if ! defined( Exec["Add ${p}"] ) {
    exec { "Add ${p}":
      command => "${path}/bin/python ${path}/create_project.py -o ${organization} -t ${team} -l ${platform} -p ${project}",
      creates => "${path}/dsn/${p}",
      require => File["${path}/create_project.py"],
    }
  }

}
