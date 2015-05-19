require 'spec_helper'
require 'puppet_x/ldapquery'
require 'net/ldap'

describe 'PuppetX::LDAPquery' do
  describe 'results' do
    let (:conf) { {
        :host => 'ldap.example.com',
        :port => 9009,
    } }

    let (:base) { 'dc=example,dc=com' }

    it "should fail with no filter" do
      filter = ''
      attributes = ['uid']
      expect { PuppetX::LDAPquery.new(filter, attributes).results }.to raise_error
    end

    it "should not fail when using defaults in puppet.conf" do
      filter = '(uid=zach)'
      attributes = ['uid']
      l = PuppetX::LDAPquery.new(filter, attributes, base)
      expect { l.get_config }.to_not raise_error
    end

    it 'should return the desired results' do
      filter = '(uid=zach)'
      attributes = ['uid']

      wanted = [{"dn"=>"uid=zach,ou=users,dc=puppetlabs,dc=com", "uid"=>"zach"}]
      entries = Marshal.load(File.read("spec/fixtures/entries_single.obj"))

      l = PuppetX::LDAPquery.new(filter, attributes, base)

      expect(l).to receive(:get_entries).and_return(entries)
      expect(l.results).to match(wanted)
    end

    context "a multivalued attribute is requested" do
      it 'should return the attribute values as an array to the attribute' do
        filter = '(uid=zach)'
        attributes = ['objectClass']

        wanted = [{"dn"=>"uid=zach,ou=users,dc=puppetlabs,dc=com",
                  "objectclass"=> [
                    "posixAccount",
                    "shadowAccount",
                    "inetOrgPerson",
                    "puppetPerson",
                    "ldapPublicKey",
                    "top"]}]

        entries = Marshal.load(File.read("spec/fixtures/entries_objectClass.obj"))

        l = PuppetX::LDAPquery.new(filter, attributes, base)
        expect(l).to receive(:get_entries).and_return(entries)
        expect(l.results).to match(wanted)
      end
      it 'should return the attributes without new lines' do
        filter = '(uid=zach)'
        attributes = ['sshPublicKey']

        wanted = [{"dn"=>"uid=zach,ou=users,dc=puppetlabs,dc=com",
                  "sshpublickey"=>
        ["ssh-rsa AAAAB...1== user@somewhere",
        "ssh-rsa AAAAB...2== user@somewhereelse"]}]

        entries = Marshal.load(File.read("spec/fixtures/entries_multivalue.obj"))

        l = PuppetX::LDAPquery.new(filter, attributes, base)
        expect(l).to receive(:get_entries).and_return(entries)
        expect(l.results).to match(wanted)
      end
    end
  end
end
