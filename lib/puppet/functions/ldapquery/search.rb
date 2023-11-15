# frozen_string_literal: true

# @summary Provides a search query interface to LDAP server(s). This function is a replacement for `ldapquery::query`.
Puppet::Functions.create_function(:'ldapquery::search') do
  begin
    require 'net/ldap'
  rescue StandardError
    Puppet.warn('Missing net/ldap gem required for ldapquery::search() function')
  end

  local_types do
    type 'LDAPArgs = Hash' # TODO: Turn this into an exciting struct?
  end

  # @param base
  #   The search base to use for this query.  If set to `undef`, the `base` must be set as a default in `ldapquery.yaml` instead.
  # @param filter
  #   The LDAP search filter to use during the query. If set to `undef`, the default `objectclass=*` will be used.
  # @param attributes
  #   The LDAP attributes to return from the server.
  # @param ldap_args
  #   A Hash containing the options used when connecting to the LDAP server(s). See the [net-ldap documentation](https://www.rubydoc.info/github/ruby-ldap/ruby-net-ldap/Net%2FLDAP:initialize) for all the options you can use.
  #   This configuration is merged with, (and overrides), any options loaded from `/etc/puppetlabs/puppet/ldapquery.yaml`.  If omitted, `ldapquery.yaml` must contain all the options you need.
  # @param scope
  #   The LDAP search scope, (indicates the set of entries at or below the search base DN that may be considered potential matches for a search operation).
  # @param search_timeout
  #   The maximum time in seconds allowed for a search. If not specified, defaults to 10 seconds.
  #   Note, there is a separate net-ldap TCP `connect_timout` (defaulting to 5 seconds) that can be specified via `ldap_args`, (or globally via `ldapquery.yaml`).
  # @param soft_fail
  #   When set to `true`, the function will return `undef` if it experiences an issue connecting to the LDAP server of performing the query.
  #   Defaults to `false`, which causes the function to fail with an exception if it can't return the requested data.
  #
  # @return [Array[String]] The returned query results.
  # @return [Undef] Returns `undef` if `soft_fail` was set to `true` and an error was encountered.
  #
  # @example Querying an LDAP server on the default port with a username and password
  #   ldapquery::search(
  #     'dc=acme,dc=example,dc=com',
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #     {
  #       host => 'ldap.example.com',
  #       auth => {
  #         method   => simple,
  #         username => 'ldapuser',
  #         password => 'ldappassword',
  #       },
  #     },
  #   )
  # @example Trying to connect to multiple LDAP servers to perform the search
  #   ldapquery::search(
  #     'dc=acme,dc=example,dc=com',
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #     {
  #       hosts => [
  #         [ldap1.example.com, 389],
  #         [ldap2.example.com, 389],
  #       ],
  #       auth => {
  #         method   => simple,
  #         username => 'ldapuser',
  #         password => 'ldappassword',
  #       },
  #     },
  #   )
  # @example Not specifying `ldap_args` as all options needed exist in `ldapquery.yaml`.
  #   # /etc/puppetlabs/puppet/ldapquery.yaml
  #   # ---
  #   # base: dc=acme,dc=example,dc=com
  #   # host: ldap.example.com
  #   # auth:
  #   #   method: simple
  #   #   username: ldapuser
  #   #   password: ldappassword
  #
  #   ldapquery::search(
  #     undef, # `base` can also be set in `ldapquery.yaml`
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #   )
  # @example Querying an LDAP server using TLS and the system cert store
  #   ldapquery::search(
  #     'dc=acme,dc=example,dc=com',
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #     {
  #       host       => 'ldap.example.com',
  #       port       => 636,
  #       encryption => {
  #         method => simple_tls,
  #       },
  #       auth       => {
  #         method   => simple,
  #         username => 'ldapuser',
  #         password => 'ldappassword',
  #       },
  #     },
  #   )
  # @example Querying an LDAP server using TLS with a custom CA certificate
  #   ldapquery::search(
  #     'dc=acme,dc=example,dc=com',
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #     {
  #       host       => 'ldap.example.com',
  #       port       => 636,
  #       encryption => {
  #         method      => simple_tls,
  #         tls_options => { ca_file => '/path/to/custom-ca.crt' },
  #       },
  #       auth       => {
  #         method   => simple,
  #         username => 'ldapuser',
  #         password => 'ldappassword',
  #       },
  #     },
  #   )
  # @example Querying an LDAP server on the standard port but then encrypting all traffic using STARTTLS
  #   ldapquery::search(
  #     'dc=acme,dc=example,dc=com',
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #     {
  #       host       => 'ldap.example.com',
  #       port       => 389, # Default included for clarity
  #       encryption => {
  #         method => start_tls,
  #       },
  #       auth       => {
  #         method   => simple,
  #         username => 'ldapuser',
  #         password => 'ldappassword',
  #       },
  #     },
  #   )
  # @example Specifying a 1 minute `search_timeout`, (and `connect_timeout` via `ldapquery.yaml`)
  #   # /etc/puppetlabs/puppet/ldapquery.yaml
  #   # ---
  #   # base: dc=acme,dc=example,dc=com
  #   # host: ldap.example.com
  #   # auth:
  #   #   method: simple
  #   #   username: ldapuser
  #   #   password: ldappassword
  #   # connect_timeout: 30
  #
  #   ldapquery::search(
  #     undef, # Use `base` from `ldapquery.yaml`
  #     '(objectClass=dnsDomain)',
  #     ['dc'],
  #     {}, # Use `ldapquery.yaml`
  #     'sub',
  #     60,
  #   )
  dispatch :search do
    param 'Optional[String[1]]', :base
    param 'Optional[String[1]]', :filter
    optional_param 'Array[String[1],1]', :attributes
    optional_param 'Optional[LDAPArgs]', :ldap_args
    optional_param 'Optional[Enum["sub","base","single"]]', :scope
    optional_param 'Optional[Integer[1]]', :search_timeout
    optional_param 'Optional[Boolean]', :soft_fail
    return_type 'Optional[Array]'
  end

  def search(base, filter, attributes = nil, ldap_args = nil, scope = nil, search_timeout = nil, soft_fail = nil)
    # Set the defaults for optional_params in the code instead of function signature so that they can be omitted _or_ set to `undef`
    attributes = [] if attributes.nil?
    ldap_args = {} if ldap_args.nil?
    scope = 'sub' if scope.nil?
    search_timeout = 10 if search_timeout.nil?
    soft_fail = false if soft_fail.nil?

    conf = yaml_conf.merge(ldap_args)

    conf.transform_keys!(&:to_sym)
    conf.each do |_k, v|
      v.transform_keys!(&:to_sym) if v.is_a? Hash
    end

    conf[:encryption][:method] = conf[:encryption][:method].to_sym if conf.dig(:encryption, :method)
    conf[:auth][:method] = conf[:auth][:method].to_sym if conf.dig(:auth, :method)

    ldap = Net::LDAP.new(conf)

    search_args = {
      base: base,
      attributes: attributes,
      scope: scope_object(scope),
      time: search_timeout,
      return_result: false,
    }.compact

    search_args[:filter] = Net::LDAP::Filter.construct(filter) if filter

    perform_search(ldap, search_args, soft_fail)
  end

  def yaml_conf
    yamlfile = "#{Puppet.settings[:confdir]}/ldapquery.yaml"
    return {} unless File.exist? yamlfile

    Puppet.debug("ldapquery::search(): Loading default settings from #{yamlfile}")
    YAML.load_file(yamlfile)
  end

  def scope_object(scope)
    case scope
    when 'sub'
      Net::LDAP::SearchScope_WholeSubtree
    when 'base'
      Net::LDAP::SearchScope_BaseObject
    when 'single'
      Net::LDAP::SearchScope_SingleLevel
    end
  end

  def perform_search(ldap, search_args, soft_fail)
    results = []

    start_time = Time.now

    begin
      if ldap.search(search_args) { |entry| results << format_entry(entry) }
        Puppet.debug "ldapquery::search(:) LDAP search result was #{ldap.get_operation_result.code}:#{ldap.get_operation_result.message}"
      else
        message = "ldapquery::search(): LDAP search FAILED with #{ldap.get_operation_result.code}:#{ldap.get_operation_result.message}"
        raise Puppet::ParseError, message unless soft_fail

        Puppet.warning message
        return nil
      end
    rescue Net::LDAP::Error, Net::LDAP::ConnectionError => e
      raise e unless soft_fail

      Puppet.warning "ldapquery::search() LDAP ERROR encountered: #{e.message}"
      return nil
    end

    Puppet.debug "ldapquery::search() LDAP search result was: #{ldap.get_operation_result.code}:#{ldap.get_operation_result.message}"

    time_delta = format('%.3f', Time.now - start_time)
    Puppet.debug("ldapquery::search(): Searching #{search_args[:base]} for #{search_args[:attributes]} using #{search_args[:filter]} took #{time_delta} seconds and returned #{results.length} results")

    results
  end

  def format_entry(entry)
    entry_data = {}
    entry.each do |attribute, values|
      attr = attribute.to_s
      value_data = []
      Array(values).flatten.each do |v|
        value_data << v.to_s.chomp
      end
      entry_data[attr] = value_data
    end
    entry_data
  end
end
