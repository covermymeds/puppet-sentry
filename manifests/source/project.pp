# == Define: sentry::source::project
#
# This is a defined type that creates a Sentry project if it 
# doesn't exist.
#
# === Parameters
# project: the name of the project
# platform: the language used by this project
# path: the virtualenv path to use for Sentry
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
  $project,
  $platform,
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
  # Projects are created in the default organization and team
  # as defined in the `sentry::init`.  Multiple projects can use
  # the same name as long as they are in different teams (or
  # organizations).  This requires manual modification of projects
  # after they have been created, and is outside the scope of
  # this module.  Additionally, automatic creation of a new project
  # may fail if a prior project of the same name still has a DSN file
  # present at `${path}/dsn/${project}`

  if ! defined( Exec["Add ${project}"] ) {
    exec { "Add ${project}":
      command => "${path}/bin/python ${path}/create_project.py -p ${project} -l ${platform}",
      creates => "${path}/dsn/${project}",
      require => File["${path}/create_project.py"],
    }
  }

}
