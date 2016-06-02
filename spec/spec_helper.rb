require 'rspec-puppet/spec_helper'
require 'puppetlabs_spec_helper/puppetlabs_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
end

shared_context 'RedHat 7' do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '7.2',
      operatingsystemmajrelease: '7',
      os: {
        architecture: "x86_64",
        family: "RedHat",
        hardware: "x86_64",
        name: "RedHat",
        release: {
          full: "7.2",
          major: "7",
          minor: "2"
        },
        selinux: {
          config_mode: "permissive",
          config_policy: "targeted",
          current_mode: "permissive",
          enabled: true,
          enforced: false,
          policy_version: "28"
        }
      }
    }
  end
end
