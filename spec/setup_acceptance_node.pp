file_line { '/etc/hosts-openldap':
  path => '/etc/hosts',
  line => "${facts['openldap_ip']} openldap",
}

package { 'net-ldap':
  ensure   => present,
  provider => 'puppet_gem',
}
