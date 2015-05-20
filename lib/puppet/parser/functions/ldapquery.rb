require 'puppet_x/ldapquery'

begin
  require 'net/ldap'
rescue
  Puppet.warn("Missing net/ldap gem required for ldapquery() function")
end

Puppet::Parser::Functions.newfunction(:ldapquery,
                                      :type => :rvalue) do |args|

  if args.size > 2
    raise Puppet::ParseError, "Too many arguments received in ldapquery()"
  end

  filter, attributes = args

  return PuppetX::LDAPquery.new(filter, attributes).results
end
