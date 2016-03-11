require_relative '../../../puppet_x/ldapquery'

begin
  require 'net/ldap'
rescue
  Puppet.warn("Missing net/ldap gem required for ldapquery() function")
end

Puppet::Parser::Functions.newfunction(:ldapquery,
                                      :type => :rvalue) do |args|

  if args.size > 3
    raise Puppet::ParseError, "Too many arguments received in ldapquery()"
  end

  filter, attributes, base = args

  attributes ||= []
  base ||= Puppet[:ldapbase]

  return PuppetX::LDAPquery.new(filter, attributes, base).results
end
