# frozen_string_literal: true

# @summary Provides a query interface to an LDAP server
Puppet::Functions.create_function(:'ldapquery::query') do
  begin
    require 'net/ldap'
  rescue StandardError
    Puppet.warn('Missing net/ldap gem required for ldapquery::query() function')
  end

  local_types do
    type <<~TYPE_ALIAS
      Options = Struct[
        Optional[base]           => String[1],
        Optional[cafile]         => String[1],
        Optional[connecttimeout] => Integer[0],
        Optional[password]       => String[1],
        Optional[port]           => Integer[0,65535],
        Optional[scope]          => Enum['sub','base','single'],
        Optional[server]         => String[1],
        Optional[time]           => Integer[0],
        Optional[tls]            => Variant[Enum['simple_tls','start_tls'],Boolean],
        Optional[user]           => String[1],
      ]
    TYPE_ALIAS
  end

  # @param filter
  #   The filter you want to query the LDAP server with
  # @param attributes
  #   Which attributes you want to query
  # @param options
  #   Function options where you can specify ruby net/ldap related options
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
  attr_accessor :ca_file
  attr_accessor :connect_timeout
  attr_accessor :host
  attr_accessor :password
  attr_accessor :port
  attr_accessor :scope
  attr_accessor :time
  attr_accessor :tls
  attr_accessor :user

  def query(filter, attributes = [], options = {})
    @filter = filter
    @attributes = attributes
    @base = options['base'] || Puppet.settings[:ldapbase]
    @time = options['time'] || 10

    scope = options['scope'] || 'sub'
    @scope =
      case scope
      when 'sub'
        Net::LDAP::SearchScope_WholeSubtree
      when 'base'
        Net::LDAP::SearchScope_BaseObject
      when 'single'
        Net::LDAP::SearchScope_SingleLevel
      end

    @host = options['server'] || Puppet.settings[:ldapserver]
    raise Puppet::ParseError, 'Missing required setting "server" or "ldapserver" in puppet.conf' if @host.nil?

    @port = options['port'] || Puppet.settings[:ldapport]
    @port ||= 363
    @user = options['user'] || Puppet.settings[:ldapuser]
    @password = options['password'] || Puppet.settings[:ldappassword]
    @connect_timeout = options['connecttimeout'] || Puppet.settings[:ldapconnecttimeout]
    @connect_timeout ||= 5

    tls = options['tls'] || Puppet.settings[:ldaptls]
    tls ||= false
    @tls =
      case tls
      when 'simple_tls'
        :simple_tls
      when 'start_tls'
        :start_tls
      when true
        case @port
        when 363
          :start_tls
        else
          :simple_tls
        end
      when false
        nil
      end

    @ca_file = options['cafile'] || Puppet.settings[:ldaptlscafile]
    @ca_file ||= "#{Puppet.settings[:confdir]}/ldap_ca.pem"

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
      time: @time
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
    # Convert settings to ldap config for net/ldap
    conf = {
      host: @host,
      port: @port
    }

    conf[:connect_timeout] = @connect_timeout unless @connect_timeout.nil?

    conf[:auth] =
      if (@user == '') || (@password == '')
        {
          method: :anonymous
        }
      else
        {
          method: :simple,
          username: @user,
          password: @password
        }
      end

    unless @tls.nil?
      conf[:encryption] = {
        method: @tls
      }
      if File.file?(@ca_file)
        Puppet.debug("Using #{@ca_file} as CA for TLS connection")
        conf[:encryption][:tls_options] = { ca_file: @ca_file }
      else
        Puppet.debug("#{@ca_file} not found, using default CAs installed in your system")
      end
    end

    conf
  end
end
