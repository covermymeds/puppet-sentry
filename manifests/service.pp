# == Class: sentry::service
#
# This class is meant to be called from sentry.
# It ensures the service is running via systemd
#
# === Parameters
#
# user: UNIX user to run Sentry services
# group: UNIX group to run Sentry services
# path: path to Sentry installation / virtualenv
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
class sentry::service (
  $user = $sentry::user,
  $group = $sentry::group,
  $path = $sentry::path,
) {

  exec { 'enable-sentry-services':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    path        => '/bin:/sbin',
  }

  file { '/etc/systemd/system/sentry-worker.service':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('sentry/sentry-worker.service.erb'),
    notify  => Exec['enable-sentry-services'],
  }

  service { 'sentry-worker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => [ File['/etc/systemd/system/sentry-worker.service'],
                    User[$user],
                  ],
  }

  # if the Sentry config changes, do a full restart of the Sentry Celery workers
  exec { 'restart-sentry-worker':
    command     => '/usr/bin/systemctl stop sentry-worker; /usr/bin/systemctl start sentry-worker',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Class['::sentry::config'],
  }

  # Setup log rotation for the sentry-worker process
  logrotate::rule { 'sentry-worker':
    ensure       => present,
    path         => '/var/log/sentry/sentry-worker.log',
    create       => true,
    compress     => true,
    missingok    => true,
    rotate       => 14,
    ifempty      => false,
    create_mode  => '0644',
    create_owner => $user,
    create_group => $group,
  }

}
