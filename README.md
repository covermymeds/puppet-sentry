puppet-sentry
======

[Sentry](https://www.getsentry.com) is "a modern error logging and aggregation platform."  This module installs the [on-premise](https://docs.getsentry.com/on-premise/) open source version of Sentry.

Installation requires RHEL 7, and depends on Python and apache with `mod_wsgi`.  These module dependencies are explicitly listed. Sentry also requires a database (PostgreSQL), memcached, and Redis which are not included in this module. Please see the [Modules we use](#modules-we-use) to satify those dependencies below.

If LDAP values are defined for Sentry, the [getsentry-ldap-auth](https://github.com/banno/getsentry-ldap-auth) plugin is installed.

# Usage
Install the latest version of Sentry.  The default configuration places all of the dependencies on localhost which is likely only useful for a development scenario.
```
class { 'sentry': }
```

A more realistic use case with roles and profiles might look like this.

* **role/manifests/sentry.pp**
```
class role::sentry {

  include profile::sentry
  include profile::memcached

}
```

* **profile/manifests/sentry.pp**
```
class profile::sentry {

  include profile::postgresql_client
  include ::sentry

  Class['profile::postgresql_client'] ->
    Class['::sentry']

}
```

* **hieradata/hosts/sentry.example.com.yaml**
```
---
classes:
  - role::sentry
sentry::db_host: 'postgresql.example.com'
sentry::db_name: 'sentry'
sentry::db_user: 'sentry'
sentry::db_password: <redacted>
sentry::sentry_vhost: 'sentry.example.com'
sentry::ldap_host: 'ldap.example.com'
sentry::ldap_user: 'sentry_ldap@example.com'
sentry::ldap_password: <redacted>
sentry::ldap_domain: 'example'
sentry::ldap_base_ou: 'dc=example,dc=com'
sentry::sentry_group_base: 'OU=Some Group,OU=Some Other Group,DC=example,DC=com'
sentry::sentry_group_dn: 'CN=Sentry_Group,OU=Some Other Group,DC=example,DC=com'
sentry::redis_host: 'redis.example.com'
sentry::smtp_host: 'smtp.example.com'
sentry::admin_email: 'admin@example.com'
sentry::admin_password: <redacted>
sentry::organization: 'Your Organization Name'
sentry::team: 'Default Team Name'
sentry::secret_key: <some secret key>
sentry::path: '/var/lib/sentry'
sentry::version: '7.7.1'
```

## Automation
In addition to the installation of Sentry, this module also provides several useful automation hooks to facilitate the automatic creation of new projects.

`sentry::source::export` is a defined type that exports a `sentry::source::project` resource.  You can use this module in your application manifests.

The main `sentry` class includes `sentry::server::collect`, which collects all of the exported `sentry::source::project` resources from your app servers.  Each collected resource will create a Sentry project if it does not already exist.  New projects will be created within your default Sentry organization and team.

You may optionally also publish each of your projects' DSNs.  With a simple custom fact (see the `examples` directory in this repo) your applications can automatically look up their DSN, and you can then embed that DSN wherever may be appropriate for consumption for your apps.

We use this pattern to ensure that all of our apps automatically report to Sentry. This frees us from the manual task of creating a new Sentry resource for each new application.

# Modules we use
* [Postgresql](https://github.com/puppetlabs/puppetlabs-postgresql)
* [Redis](https://github.com/covermymeds/puppet-redis)
* [Memcached](https://github.com/saz/puppet-memcached)


