# Puppet-LDAPquery

[![Build Status](https://travis-ci.org/xaque208/puppet-ldapquery.svg?branch=master)](https://travis-ci.org/xaque208/puppet-ldapquery)

A Puppet function to query LDAP.


## Sample Usage

### On the Master

You must set the necessary variables in `puppet.conf` so the master can connect
to your LDAP server.

Add something like the following to your master's manifest.


    $ldap_base   = hiera('ldap_base') # dc=example,dc=com
    $ldap_user   = hiera('ldap_user') # cn=ldapuser,dc=puppetlabs,dc=com
    $ldap_pass   = hiera('ldap_pass') # ultrasecure

    package { 'net-ldap':
      ensure   => present,
      provider => 'gem'
    }

    file { '/etc/puppet/ldap_ca.pem':
      owner  => 'root',
      group  => '0',
      mode   => '0644',
      source => /path/to/my/ldap/ca.pem,
    }

    Ini_setting {
      ensure  => present,
      section => 'master',
      path    => '/etc/puppet/puppet.conf',
    }

    ini_setting { 'ldapserver':
      setting => 'ldapserver',
      value   => 'ldap.example.com',
    }

    ini_setting { 'ldapport':
      setting => 'ldapport',
      value   => '636',
    }

    ini_setting { 'ldapbase':
      setting => 'ldapbase',
      value   => $ldap_base,
    }


    ini_setting { 'ldapuser':
      setting => 'ldapuser',
      value   => $ldap_user,
    }

    ini_setting { 'ldappassword':
      setting => 'ldappassword',
      value   => $ldap_pass,
    }

    ini_setting { 'ldaptls':
      setting => 'ldaptls',
      value   => true,
    }


### In manifest

The `ldapquery` function is simple.  Just passing an `rfc4515` search filter
will return the results of the query in list form.  Optionally, a list of
attributes of which to return the values may also be passed.

Consider the following manifest.

    $attributes = [
      'loginshell',
      'uidnumber',
      'uid',
      'homedirectory',
    ]

    $zach = ldapquery('(uid=zach)', $attributes)


