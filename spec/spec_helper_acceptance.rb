# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

ENV['BEAKER_FACTER_OPENLDAP_IP'] = File.read(File.expand_path('~/OPENLDAP_IP')).chomp

configure_beaker do |host|
  install_puppet_module_via_pmt_on(host, 'puppetlabs-stdlib')
end
