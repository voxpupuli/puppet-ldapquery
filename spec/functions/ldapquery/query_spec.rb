# frozen_string_literal: true

require 'spec_helper'

describe 'ldapquery::query' do
  let(:entries) do
    Marshal.load(File.read(File.join('spec', 'fixtures', fixture))) # rubocop:disable Security/MarshalLoad
  end

  it 'exists' do
    is_expected.not_to be_nil
  end

  it 'does not fail when using defaults in puppet.conf' do
    expect { subject.func.ldap_config }.not_to raise_error
  end

  describe 'calling the function' do
    let(:base) { 'dc=example,dc=com' }
    let(:filter) { '(uid=zach)' }

    before do
      allow(subject.func).to receive(:entries).and_return(entries)
    end

    describe 'simple case' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:attributes) { ['uid'] }
      let(:wanted) { [{ 'dn' => ['uid=zach,ou=users,dc=puppetlabs,dc=com'], 'uid' => ['zach'] }] }
      let(:fixture) { 'entries_single.obj' }

      before do
        allow(subject.func).to receive(:entries).and_return(entries)
      end

      it { is_expected.to run.with_params(filter, attributes, 'base' => base).and_return(wanted) }
    end

    context 'a multivalued attribute is requested' do
      describe 'attribute values as an array to the attribute' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:attributes) { ['objectClass'] }
        let(:wanted) { [{ 'dn' => ['uid=zach,ou=users,dc=puppetlabs,dc=com'], 'objectclass' => %w[posixAccount shadowAccount inetOrgPerson puppetPerson ldapPublicKey top] }] }
        let(:fixture) { 'entries_objectClass.obj' }

        it { is_expected.to run.with_params(filter, attributes, 'base' => base).and_return(wanted) }
      end

      describe 'attributes without new lines' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:attributes) { ['sshPublicKey'] }
        let(:wanted) { [{ 'dn' => ['uid=zach,ou=users,dc=puppetlabs,dc=com'], 'sshpublickey' => ['ssh-rsa AAAAB...1== user@somewhere', 'ssh-rsa AAAAB...2== user@somewhereelse'] }] }
        let(:fixture) { 'entries_multivalue.obj' }

        it { is_expected.to run.with_params(filter, attributes, 'base' => base).and_return(wanted) }
      end
    end
  end
end
