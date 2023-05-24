# Puppet-LDAPquery

[![CI](https://github.com/voxpupuli/puppet-ldapquery/actions/workflows/ci.yml/badge.svg)](https://github.com/voxpupuli/puppet-ldapquery/actions/workflows/ci.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/ldapquery.svg)](https://forge.puppetlabs.com/puppet/ldapquery)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/ldapquery.svg)](https://forge.puppetlabs.com/puppet/ldapquery)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/ldapquery.svg)](https://forge.puppetlabs.com/puppet/ldapquery)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/ldapquery.svg)](https://forge.puppetlabs.com/puppet/ldapquery)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-ldapquery.svg)](LICENSE)

A Puppet function to query LDAP.

## Dependencies

The Ruby `net-ldap` gem is required to communicate with LDAP. To install this use the following command: `puppetserver gem install net-ldap`.  Version 0.11.0 or newer of `net-ldap` is required.

In some environments, when `ldapquery::search()` is used on Puppet Server, an error
like the following may appear.

    Error while evaluating a Function Call

Please make sure you have `jruby-openssl` at least `0.10.1` with `puppetserver
gem install jruby-openssl -v 0.10.1`.

## REFERENCE

For detailed information on this module's functions, see the [REFERENCE.md](https://github.com/voxpupuli/puppet-ldapquery/blob/master/REFERENCE.md)

## Usage

This module provides two function variants. ``ldapquery::query`` is the legacy implementation where LDAP connection options are sourced from `puppet.conf` on your Puppetserver.

`ldapquery::search` is the replacement implementation. It provides more flexibility than `ldapquery::query` and doesn't reuse `ldap` related settings from `puppet.conf`. All connection options can be specified in the function call and can be different each time you call the function. For convenience, it is also possible to specify defaults to be used in all functions calls in `/etc/puppetlabs/puppet/ldapquery.yaml`. This can also be useful if you want to manage the credentials used to contact your ldap server separately from the code that calls the function.

### Simple example

```pupppet
ldapquery::search(
  'dc=acme,dc=example,dc=com', # Search base
  '(objectClass=dnsDomain)',   # filter
  ['dc'],                      # attributes
  {                            # connection arguments
    host => 'ldap.example.com',
    auth => {
      method   => simple,
      username => 'ldapuser',
      password => 'ldappassword',
    },
  },
)

```

A full set of examples can be found in the [REFERENCE.md](https://github.com/voxpupuli/puppet-ldapquery/blob/master/REFERENCE.md) file.

### LDAP connection arguments

LDAP server connection options either have to be specified when calling the function, (in the 4th argument), or configured as defaults on the puppetserver in `/etc/puppetlabs/puppet/ldapquery.yaml`

Everything that the `net-ldap` library supports should work with this function, (eg. connecting to multiple LDAP servers, using TLS etc.) The REFERENCE.MD file has many examples. The examples that follow have omitted this option for simplicity. It can be assumed they have been configured on the puppetserver.

### Filters and attributes

Simply passing the search base and an `rfc4515` search filter string to `ldapquery::search()` will return
the results of the query in list form.  Optionally, a list of attributes of which to return the values may also be passed.

Consider the following manifest. (For simplicity, the declaration of `$ldap_args` has been left off of the following examples).

```Puppet
$base = 'dc=acme,dc=example,dc=com'

$filter = '(uid=zach)'

$attributes = [
  'loginshell',
  'uidnumber',
  'uid',
  'homedirectory',
]

$zach = ldapquery::search($base, $filter, $attributes)
```

Assuming there is only one LDAP object with the `uid=zach`, then the variable
`$zach` now holds the following data structure:

```Ruby
[
  {
    'uid'           => ['zach'],
    'loginshell'    => ['/bin/zsh'],
    'uidnumber'     => ['123'],
    'homedirectory' => ['/var/users/zach'],
  }
]
```

**Note that the key values are an array.**  This should make implementation code simpler, if a bit more verbose, and avoid having to check if the value is an array or a string, because it always is.

Here is a slightly more complicated example that will generate *virtual*
`ssh_authorized_key` resources for every 'posixAccount' that has a non-empty
'sshPublicKey' attribute.

```Puppet
$base = 'dc=acme,dc=example,dc=com'

$attributes = [
  'uid',
  'sshPublicKey'
]

$key_query = '(&(objectClass=ldapPublicKey)(sshPublicKey=*)(objectClass=posixAccount))'

$key_results = ldapquery::search($base, $key_query, $attributes)
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


### The legacy function `ldapquery::query`

This implementation has been replaced by the more advanced version `ldapquery::search` documented above. It should be considered DEPRECATED and may be removed in a future release.  For completeness, documentation specific to this function is retained in this release and follows.

#### On the Puppetserver

You must set the necessary variables in `puppet.conf` so the puppetserver can connect
to your LDAP server. You also have to place the CA certificate (and possible intermediate certificates) of the tls certificate of your ldap server in pem format in a file called ldap_ca.pem in your puppetconf folder.

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

file { '/etc/puppetlabs/puppet/ldap_ca.pem':
  owner  => 'root',
  group  => '0',
  mode   => '0644',
  source => /path/to/my/ldap/ca.pem,
}

Ini_setting {
  ensure  => present,
  section => 'master',
  path    => '/etc/puppetlabs/puppet/puppet.conf',
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
