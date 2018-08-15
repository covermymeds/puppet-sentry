# == Class: sentry
#
# Install Sentry from PyPI and configure an Apache mod_wsgi vhost
#
# === Authors
# Dan Sajner <dsajner@covermymeds.com>
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
# === License
# Released under the terms of the MIT license.  See LICENSE for more details
#
# === Params
#
# @param admin_email the admin user's email address; also used as login name (root@localhost)
# @param admin_password the admin user's password (admin)
# @param apache_enabled Whether to enable/start the apache service
# @param bootstrap Whether this node will bootstrap the database, admin, etc
# @param custom_config array of custom configs to put into config.yml (undef)
# @param custom_settings arrray of custom settings to put into sentry.conf.py (undef)
# @param db_host the PostgreSQL database host (localhost)
# @param db_name the name of the PostgreSQL database to use (sentry)
# @param db_password the DB user's password (sentry)
# @param db_port the PostgreSQL database port (5432)
# @param db_user the user account with which to connect to the database (sentry)
# @param email_from Email address sentry emails will come from
# @param extensions hash of sentry extensions and source URL to install (sentry-github)
# @param group UNIX group to own virtualenv, and run background workers (sentry)
# @param ldap_auth_version version of the sentry_ldap_auth Python module to install (present)
# @param ldap_base_ou LDAP connection details used for creating local user accounts from AD users
# @param ldap_domain LDAP connection details used for creating local user accounts from AD users
# @param ldap_group_base LDAP connection details used for creating local user accounts from AD users
# @param ldap_group_dn LDAP connection details used for creating local user accounts from AD users
# @param ldap_host LDAP connection details used for creating local user accounts from AD users
# @param ldap_user LDAP bind user
# @param ldap_password LDAP bind password
# @param memcached_host name or IP of memcached server (localhost)
# @param memcached_port port to use for memcached (11211)
# @param metrics_enable whether to enable the sentry metrics (false)
# @param metrics_backend which metrics backend to enable (statsd)
# @param organization default organization to create, and in which to create new users
# @param path path into which to install Sentry, and create the virtualenv (/srv/sentry)
# @param project Default project name
# @param redis_host name or IP of Redis server (localhost)
# @param redis_port port to use for Redis (6379)
# @param secret_key string used to hash cookies (fqdn_rand_string(40))
# @param smtp_host name or IP of SMTP server (localhost)
# @param ssl_ca Apache SSL CA cert
# @param ssl_chain Apache SSL Intermediate CA cert
# @param ssl_cert Apache SSL public cert
# @param ssl_key Apache SSL private key
# @param statsd_host hostname of statsd server (localhost)
# @param statsd_port port for statsd server (8125)
# @param url source URL from which to install Sentry.  (false, use PyPI)
# @param user UNIX user to own virtualenv, and run background workers (sentry)
# @param version the Sentry version to install
# @param url_prefix Sentry URL for error reporting, used when generating DSN files
# @param vhost the URL at which users will access the Sentry GUI
# @param wsgi_processes mod_wsgi processes
# @param wsgi_threads mod_wsgi threads
# @param worker_concurrency number of concurrent workers (processors.count)
# @param workers_enabled Should the worker and cron services be running
#
class sentry (
  $admin_email                      = $sentry::params::admin_email,
  $admin_password                   = $sentry::params::admin_password,
  Boolean $apache_enabled           = true,
  Boolean $bootstrap                = $sentry::params::bootstrap,
  $custom_config                    = $sentry::params::custom_config,
  $custom_settings                  = $sentry::params::custom_settings,
  $db_host                          = $sentry::params::db_host,
  $db_name                          = $sentry::params::db_name,
  $db_password                      = $sentry::params::db_password,
  $db_port                          = $sentry::params::db_port,
  $db_user                          = $sentry::params::db_user,
  $email_from                       = $sentry::params::email_from,
  $extensions                       = $sentry::params::extensions,
  $group                            = $sentry::params::group,
  $ldap_auth_version                = $sentry::params::ldap_auth_version,
  $ldap_base_ou                     = $sentry::params::ldap_base_ou,
  $ldap_domain                      = $sentry::params::ldap_domain,
  $ldap_group_base                  = $sentry::params::ldap_group_base,
  $ldap_group_dn                    = $sentry::params::ldap_group_dn,
  $ldap_host                        = $sentry::params::ldap_host,
  $ldap_user                        = $sentry::params::ldap_user,
  $ldap_password                    = $sentry::params::ldap_password,
  $memcached_host                   = $sentry::params::memcached_host,
  $memcached_port                   = $sentry::params::memcached_port,
  Boolean         $metrics_enable   = $sentry::params::metrics_enable,
  Enum['statsd']  $metrics_backend  = $sentry::params::metrics_backend,
  $organization                     = $sentry::params::organization,
  $path                             = $sentry::params::path,
  $project                          = $sentry::params::project,
  $redis_host                       = $sentry::params::redis_host,
  $redis_port                       = $sentry::params::redis_port,
  $secret_key                       = $sentry::params::secret_key,
  $server_tokens                    = $sentry::params::server_tokens,
  $smtp_host                        = $sentry::params::smtp_host,
  $ssl_ca                           = $sentry::params::ssl_ca,
  $ssl_chain                        = $sentry::params::ssl_chain,
  $ssl_cert                         = $sentry::params::ssl_cert,
  $ssl_key                          = $sentry::params::ssl_key,
  String  $statsd_host              = $sentry::params::statsd_host,
  Integer $statsd_port              = $sentry::params::statsd_port,
  $url                              = $sentry::params::url,
  Variant[Undef,String] $url_prefix = undef,
  $user                             = $sentry::params::user,
  $cleanup_user                     = 'root',
  $version                          = $sentry::params::version,
  $vhost                            = $sentry::params::vhost,
  $wsgi_processes                   = $sentry::params::wsgi_processes,
  $wsgi_threads                     = $sentry::params::wsgi_threads,
  $worker_concurrency               = $sentry::params::worker_concurrency,
  Boolean $workers_enabled          = true,
) inherits ::sentry::params {

  if $version != 'latest' {
    if versioncmp('8.5.0', $version) > 0 {
      fail('Sentry version 8.5.0 or greater is required.')
    }
  }

  # establish resource containment
  contain '::sentry::setup'
  contain '::sentry::config'
  contain '::sentry::install'
  contain '::sentry::service'
  contain '::sentry::wsgi'

  # establish resource precedence and notifications
  Class['::sentry::setup'] ~>
  Class['::sentry::config'] ~>
  Class['::sentry::install'] ~>
  Class['::sentry::service'] ~>
  Class['::sentry::wsgi']

  # Write out a list of "team/project dsn" values to a file.
  # Apache will serve this list and Puppet will consume to set
  # custom facts for each app installed on a server
  file { "${path}/dsn_mapper.py":
    ensure  => present,
    mode    => '0755',
    content => template('sentry/dsn_mapper.py.erb'),
    require => Class['::sentry::install'],
  }

  # this creates the DSN file for each project, daily.
  cron { 'dsn_mapper':
    command => "${path}/bin/python ${path}/dsn_mapper.py",
    user    => root,
    minute  => 5,
    hour    => 2,
    require => Class['::sentry::install'],
  }

  # run the Sentry cleanup process daily
  cron { 'sentry cleanup':
    command => "${path}/bin/sentry --config=${path} cleanup --days=30",
    user    => $cleanup_user,
    minute  => 15,
    hour    => 1,
    require => Class['::sentry::install'],
  }

  file { "${path}/create_project.py":
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/sentry/create_project.py',
    require => Class['::sentry::install'],
  }

  # Collect the projects from exported resources
  include ::sentry::server::collect

}
