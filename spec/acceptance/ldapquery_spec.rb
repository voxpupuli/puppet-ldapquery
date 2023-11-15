# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ldapquery::search function' do
  context 'basic usage' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-MANIFEST
          file { '/tmp/testoutput':
            ensure  => file,
            content => ldapquery::search(
              'dc=example,dc=org',
              '(objectClass=posixAccount)',
              ['uid'],
              {
                host       => 'openldap',
                port       => 1389,
                auth       => {
                  method   => simple,
                  username => 'cn=user01,ou=users,dc=example,dc=org',
                  password => 'bitnami1',
                },
              },
            ).to_json_pretty
          }
        MANIFEST
      end
      describe file('/tmp/testoutput') do
        it { is_expected.to be_file }

        its(:content_as_json) do
          is_expected.to eq(
            [
              {
                'dn' => [
                  'cn=user01,ou=users,dc=example,dc=org'
                ],
                'uid' => [
                  'user01'
                ]
              },
              {
                'dn' => [
                  'cn=user02,ou=users,dc=example,dc=org'
                ],
                'uid' => [
                  'user02'
                ]
              }
            ]
          )
        end
      end
    end
  end
end
