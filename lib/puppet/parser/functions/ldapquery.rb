begin
  require 'net/ldap'
rescue
  Puppet.warn("Missing net/ldap gem required for ldapquery() function")
end

Puppet::Parser::Functions.newfunction(:ldapquery, :type => :rvalue) do |args|

  Puppet.debug(args.size)

  filter = args[0]
  attributes = args[1]


  host = Puppet[:ldapserver]
  port = Puppet[:ldapport]
  base = Puppet[:ldapbase]

  user     = Puppet[:ldapuser]
  password = Puppet[:ldappassword]

  tls = Puppet[:ldaptls]
  ca_file = "#{Puppet[:confdir]}/ldap_ca.pem"

  conf = {
    :host => host,
    :port => port,
  }

  if user != '' and password != ''
    conf[:auth] = {
      :method   => :simple,
      :username => user,
      :password => password,
    }
  end

  if tls
    conf[:encryption] = {
      :method      => :simple_tls,
      :tls_options => { :ca_file => ca_file }
    }
  end

  Puppet.debug(conf)
  Puppet.debug("Searching ldap base #{base} using #{filter} for #{attributes}")

  ldap = Net::LDAP.new(conf)
  filter = Net::LDAP::Filter.construct(filter)

  data = []
  ldap.search( :base => base, :filter => filter, :attributes => attributes) do |entry|
    entry_data = {}
    entry.each do |attribute, values|

      attr = attribute.to_s

      if values.is_a? Array and values.size > 1

        entry_data[attr] = []

        values.each do |v|
          entry_data[attr] << v
        end
      elsif values.is_a? Array and values.size == 1
        entry_data[attr] = values[0]
      else
        entry_data[attr] = values
      end
    end
    data << entry_data
  end
  return data
end

