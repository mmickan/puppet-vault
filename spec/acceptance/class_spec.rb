require 'spec_helper_acceptance'

describe 'vault class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'vault':
        admins        => ['vagrant'],
        puppet_app_id => 'puppet-acceptance-test-app-id',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe service('vault') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/usr/local/bin/vault') do
      it { should be_mode 555 }
    end

    describe command('vault version') do
      it { should return_stdout /Vault v0\.2\.0/ }
    end

    describe command('vault status') do
      it { should return_stdout /Sealed: false/ }
    end
  end
end
