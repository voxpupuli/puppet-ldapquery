# frozen_string_literal: true

# @summary Provides a query interface to an LDAP server
Puppet::Functions.create_function(:'ldapquery::query') do
  local_types do
    type <<~TYPE_ALIAS
      Options = Struct[
        Optional[base]   => String,
        Optional[scope]  => String,
        Optional[server] => String,
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

  def query(filter, attributes = [], options = {})
    begin
      require 'net/ldap'
    rescue StandardError
      Puppet.warn('Missing net/ldap gem required for ldapquery::query() function')
    end

    require_relative '../../../puppet_x/ldapquery'

    base = options['base'] || Puppet.settings[:ldapbase]
    scope = options['scope'] || 'sub'
    server = options['server'] || Puppet.settings[:ldapserver]

    PuppetX::LDAPquery.new(filter, attributes, base, scope, server).results
  end
end
