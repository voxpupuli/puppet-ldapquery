# frozen_string_literal: true

# @summary Provides a legacy query interface to an LDAP server
# This function uses LDAP connection options sourced from `puppet.conf` and is **DEPRECATED**. Consider migrating to `ldapquery::search` instead.
Puppet::Functions.create_function(:'ldapquery::query') do
  begin
    require 'net/ldap'
  rescue StandardError
    Puppet.warn('Missing net/ldap gem required for ldapquery::query() function')
  end

  local_types do
    type <<~TYPE_ALIAS
      Options = Struct[
        Optional[base]   => String[1],
        Optional[scope]  => Enum['sub','base','single'],
        Optional[server] => String[1],
      ]
    TYPE_ALIAS
  end

  # @param filter
  #   The filter you want to query the LDAP server with
  # @param attributes
  #   Which attributes you want to query
  # @param options
  #   Function options where you can specify `base`, `scope`, and `server`.
  #
  # @example Simple query
  #   ldapquery::query("(objectClass=dnsDomain)", ['dc'])
  # @example More complex query for ssh public keys
  #   ldapquery::query('(&(objectClass=ldapPublicKey)(sshPublicKey=*)(objectClass=posixAccount))', ['uid', 'sshPublicKey'])
  dispatch :query do
    param 'String[1]', :filter
    optional_param 'Array[String[1]]', :attributes
    optional_param 'Options', :options
  end

  attr_accessor :filter
  attr_accessor :attributes
  attr_accessor :base
  attr_accessor :host
  attr_accessor :scope

  def query(filter, attributes = [], options = {})
    @filter = filter
    @attributes = attributes
    @base = options['base'] || Puppet.settings[:ldapbase]
    @host = options['server'] || Puppet.settings[:ldapserver]

    scope = options['scope'] || 'sub'

    case scope
    when 'sub'
      @scope = Net::LDAP::SearchScope_WholeSubtree
    when 'base'
      @scope = Net::LDAP::SearchScope_BaseObject
    when 'single'
      @scope = Net::LDAP::SearchScope_SingleLevel
    end

    results
  end

  def results
    data = []
    entries.each do |entry|
      entry_data = {}
      entry.each do |attribute, values|
        attr = attribute.to_s
        value_data = []
        Array(values).flatten.each do |v|
          value_data << v.to_s.chomp
        end
        entry_data[attr] = value_data
      end
      data << entry_data
    end
    Puppet.debug(data)
    data
  end

  # Query the LDAP server for attributes using the filter
  #
  # Returns: An array of Net::LDAP::Entry objects
  def entries
    conf = ldap_config

    start_time = Time.now
    ldap = Net::LDAP.new(conf)

    search_args = {
      base: @base,
      attributes: @attributes,
      scope: @scope,
      time: 10
    }

    if @filter && !@filter.empty?
      ldapfilter = Net::LDAP::Filter.construct(@filter)
      search_args[:filter] = ldapfilter
    end

    entries = []

    begin
      ldap.search(search_args) do |entry|
        entries << entry
      end
      end_time = Time.now
      time_delta = format('%.3f', end_time - start_time)

      Puppet.debug("ldapquery(): Searching #{@base} for #{@attributes} using #{@filter} took #{time_delta} seconds and returned #{entries.length} results")
      entries
    rescue Net::LDAP::Error => e
      Puppet.debug("There was an error searching LDAP #{e.message}")
      Puppet.debug('Returning false')
      false
    end
  end

  def ldap_config
    # Load the configuration variables from Puppet
    required_vars = %i[
      ldapserver
      ldapport
    ]

    required_vars.each do |r|
      raise Puppet::ParseError, "Missing required setting '#{r}' in puppet.conf" unless Puppet[r]
    end

    port = Puppet[:ldapport]

    if Puppet[:ldapuser] && Puppet[:ldappassword]
      user     = Puppet[:ldapuser]
      password = Puppet[:ldappassword]
    end

    tls = Puppet[:ldaptls]
    ca_file = "#{Puppet[:confdir]}/ldap_ca.pem"

    conf = {
      host: @host,
      port: port
    }

    if (user != '') && (password != '')
      conf[:auth] = {
        method: :simple,
        username: user,
        password: password
      }
    end

    if tls
      conf[:encryption] = {
        method: :simple_tls
      }
      if File.file?(ca_file)
        Puppet.debug("Using #{ca_file} as CA for TLS connection")
        conf[:encryption][:tls_options] = { ca_file: ca_file }
      else
        Puppet.debug("#{ca_file} not found, using default CAs installed in your system")
      end
    end

    conf
  end
end
