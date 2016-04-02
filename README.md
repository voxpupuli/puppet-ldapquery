# Puppet-LDAPquery

[![Puppet Forge](https://img.shields.io/puppetforge/v/zleslie/ldapquery.svg)]() [![Build Status](https://travis-ci.org/xaque208/puppet-ldapquery.svg?branch=master)](https://travis-ci.org/xaque208/puppet-ldapquery)

A Puppet function to query LDAP.

## Dependencies

The Ruby `net-ldap` gem is required to communicate with LDAP.

## Sample Usage

### On the Master


You must set the necessary variables in `puppet.conf` so the master can connect
to your LDAP server.

You can simply add the static values like so:

```INI
[master]
ldaptls = true
ldapport = 636
ldapserver = ldap.example.com
ldapbase = dc=example,dc=com
ldapuser = cn=puppet,ou=people,dc=example,dc=com
ldappassword = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

Or, use Puppet to manage the values in `puppet.conf` by adding something like
the following to the manifest that manages your master's `puppet.conf`.

```Puppet
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
```


### In manifest

Simply passing an `rfc4515` search filter string to `ldapquery()` will return
the results of the query in list form.  Optionally, a list of attributes of
which to return the values may also be passed.

Consider the following manifest.

```Puppet
$attributes = [
  'loginshell',
  'uidnumber',
  'uid',
  'homedirectory',
]

$zach = ldapquery('(uid=zach)', $attributes)
```

Assuming there is only one LDAP object with the `uid=zach`, then the variable
`$zach` now holds the following data structure:

```Ruby
[
  {
    'uid' => ['zach'],
    'loginshell' => ['/bin/zsh'],
    'uidnumber' => ['123'],
    'homedirectory' => ['/var/users/zach'],
  }
]
```

**Note that the key values are an array.**  This should make implementation code simpler, if a bit more verbose, and avoid having to check if the value is an array or a string, because it always is.

Here is a slightly more complicate example that will generate *virtual*
`ssh_authorized_key` resources for every 'posixAccount' that has a non-empty
'sshPublicKey' attribute.

```Puppet
$attributes = [
  'uid',
  'sshPublicKey'
]

$key_query = '(&(objectClass=ldapPublicKey)(sshPublicKey=*)(objectClass=posixAccount))'

$key_results  = ldapquery($key_query, $attributes)
$key_results.each |$u| {
  any2array($u['sshpublickey']).each |$k| {
    $keyparts = split($k, ' ')

    # Retrieve the comment portion
    if $keyparts =~ Array[String, 3] {
      $comment  = $keyparts[2]
    } else {
      $comment  = ''
    }

    $uid = $u['uid'][0]

    @ssh_authorized_key { "${uid}_${comment}":
      user => $uid,
      type => $keyparts[0],
      key  => $keyparts[1],
      tag  => 'ldap',
    }
  }
}
```
