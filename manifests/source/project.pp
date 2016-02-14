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
# lint:ignore:parameter_documentation
define sentry::source::project (
  $organization,
  $project,
  $platform,
  $team,
  $path = $::sentry::path,
) {
# lint:endignore

  # normalize the project name to lowercase
  $proj = downcase($project)

  if ($organization == $::sentry::organization) and ($team == $::sentry::team) {
    # if this project is being created in the default team, just use
    # the project name for the Exec resource and the DSN cache file.
    $p = $proj
  } else {
    # if this project is not in the default organization and team,
    # set the DSN cache file to use the full org + team + project.
    # Be sure the uriescape the resulting string!
    $o = downcase($organization)
    $t = downcase($team)
    $p = uriescape("${o}-${t}-${proj}")
  }

  # create exactly one project, regardless of how many app
  # servers might be running the corresponding application.
  #
  # We use the full combination of org/team/project because
  # the same project name might exist in different organizations
  # or teams.
  #
  # We use `if ! defined` here because we don't want catalog
  # compilation to fail in the event that a project's platform
  # changes for any reason. Such a change might be due to an
  # unexpected error, or by intentional operator decision.
  #

  if ! defined( Exec["Add ${organization}-${team}-${project}"] ) {
    exec { "Add ${organization}-${team}-${project}":
      command => "${path}/bin/python ${path}/create_project.py -o ${organization} -t ${team} -l ${platform} -p ${project}",
      creates => "${path}/dsn/${p}",
      require => File["${path}/create_project.py"],
    }
  }

}
