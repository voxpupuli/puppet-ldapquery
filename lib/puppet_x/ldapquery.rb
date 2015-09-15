# Class: PuppetX::LDAPquery
#

module PuppetX
  class LDAPquery
    attr_reader :content

    def initialize(
      filter,
      attributes=[],
      base=Puppet[:ldapbase]
    )
      @filter = filter
      @attributes = attributes
      @base = base
    end

    def get_config
      # Load the configuration variables from Puppet
      required_vars = [
        :ldapserver,
        :ldapport,
      ]

      required_vars.each {|r|
        unless Puppet[r]
          raise Puppet::ParseError, "Missing required setting '#{r.to_s}' in puppet.conf"
        end
      }

      host = Puppet[:ldapserver]
      port = Puppet[:ldapport]

      if Puppet[:ldapuser] and Puppet[:ldappassword]
        user     = Puppet[:ldapuser]
        password = Puppet[:ldappassword]
      end

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

      return conf
    end

    def get_entries()
      # Query the LDAP server for attributes using the filter
      #
      # Returns: An array of Net::LDAP::Entry objects
      ldapfilter = @filter
      attributes = @attributes
      base = @base

      conf = self.get_config()

      start_time = Time.now
      ldap = Net::LDAP.new(conf)
      ldapfilter = Net::LDAP::Filter.construct(@filter)

      entries = []

      begin
        ldap.search(:base => base,
                    :filter => ldapfilter,
                    :attributes => attributes,
                    :time => 10) do |entry|
          entries << entry
        end
        end_time = Time.now
        time_delta = sprintf('%.3f', end_time - start_time)

        Puppet.debug("Searching #{@base} for #{@attributes} using #{@filter} took #{time_delta} seconds")
        return entries
      rescue Exception => e
        Puppet.debug('There was an error searching LDAP #{e.message}')
        Puppet.debug('Returning false')
        return false
      end
    end

    def parse_entries
      data = []
      entries = get_entries()
      entries.each do |entry|
        entry_data = {}
        entry.each do |attribute, values|

          attr = attribute.to_s

          if values.is_a? Array and values.size > 1
            entry_data[attr] = []

            values.each do |v|
              entry_data[attr] << v.chomp
            end
          elsif values.is_a? Array and values.size == 1
            entry_data[attr] = values[0].chomp
          else
            entry_data[attr] = values.chomp
          end
        end
        data << entry_data
      end
      return data
    end

    def results
      parse_entries
    end
  end
end
