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

  $params = { command => "${path}/bin/python ${path}/create_project.py -p ${project} -l ${platform}",
              creates => "${path}/dsn/${project}",
              require => File["${path}/create_project.py"],
            }
  # create exactly one project, regardless of how many app
  # servers might be running the corresponding application
  ensure_resource('exec', "Add ${project}", $params)

}
