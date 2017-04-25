# == Class: sentry::service
#
# This class is meant to be called from sentry.
# It ensures the background services are running via systemd
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
# === Params
#
# @param user UNIX user to run Sentry services
# @param group UNIX group to run Sentry services
# @param path path to Sentry installation / virtualenv
# @param workers_enabled Should the worker and cron services be running
#
class sentry::service (
  $user = $sentry::user,
  $group = $sentry::group,
  $path = $sentry::path,
  Boolean $workers_enabled = $sentry::workers_enabled,
) {

  if $workers_enabled {
    $_service_ensure = 'running'
  } else {
    $_service_ensure = 'stopped'
  }

  exec { 'enable-sentry-services':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    path        => '/bin:/sbin',
  }

  # Sentry Celery Worker
  file { '/etc/systemd/system/sentry-worker.service':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('sentry/sentry-worker.service.erb'),
    notify  => Exec['enable-sentry-services'],
  }

  service { 'sentry-worker':
    ensure     => $_service_ensure,
    enable     => $workers_enabled,
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

  # beat no longer exists
  file { '/etc/systemd/system/sentry-beat.service':
    ensure => absent,
    notify => [Exec['enable-sentry-services'], Exec['kill-deprecated-beat']],
  }

  exec { 'kill-deprecated-beat':
    command     => 'kill $(cat /var/lib/sentry/sentry-beat.pid)',
    onlyif      => 'test -e /var/lib/sentry/sentry-beat.pid',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    before      => Service['sentry-cron'],
  }

  # Sentry Cron
  file { '/etc/systemd/system/sentry-cron.service':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('sentry/sentry-cron.service.erb'),
    notify  => Exec['enable-sentry-services'],
  }

  service { 'sentry-cron':
    ensure     => $_service_ensure,
    enable     => $workers_enabled,
    hasrestart => true,
    require    => [ File['/etc/systemd/system/sentry-cron.service'],
                    User[$user],
                  ],
  }

  # if the Sentry config changes, do a full restart of the Sentry cron worker
  exec { 'restart-sentry-cron':
    command     => '/usr/bin/systemctl stop sentry-cron; /usr/bin/systemctl start sentry-cron',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Class['::sentry::config'],
  }

  # Setup log rotation
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

  logrotate::rule { 'sentry-cron':
    ensure       => present,
    path         => '/var/log/sentry/sentry-cron.log',
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
