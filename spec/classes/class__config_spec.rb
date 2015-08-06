require 'spec_helper'

describe 'vault', :type => :class do

  let(:facts) { {
    :architecture => 'amd64',
    :path         => '/usr/bin:/bin:/usr/sbin:/sbin',
  } }

  context 'config with bootstrap enabled' do
    let(:params) { {
      :admins    => ['admin'],
      :server    => true,
      :bootstrap => true,
    } }

    it { should compile.with_all_deps }

    it { should contain_file('/etc/vault').with_ensure('directory') }
    it { should contain_file('/etc/vault/ssl').with_ensure('directory') }
    it { should contain_file('/usr/local/bin/vault-bootstrap').with_mode('0700') }
    it { should contain_exec('vault-bootstrap') }
    it { should contain_file('/etc/init/vault.conf').with_mode('0444') }
    it { should contain_file('/etc/init.d/vault').with_target('/lib/init/upstart-job') }
    it { should contain_file('vault config.hcl').with_path('/etc/vault/config.hcl') }

    it { should_not contain_file('/etc/vault/ssl/vault.cert.pem') }
    it { should_not contain_file('/etc/vault/ssl/vault.key.pem') }
  end

  context 'with bootstrap disabled' do
    let(:params) { {
      :server        => true,
      :bootstrap     => false,
      :tls_cert_file => '/tmp/cert_file',
      :tls_key_file  => '/tmp/key_file',
    } }

    it { should compile.with_all_deps }

    it { should contain_file('/etc/vault/ssl/vault.cert.pem').with_source('/tmp/cert_file') }
    it { should contain_file('/etc/vault/ssl/vault.key.pem').with_source('/tmp/key_file') }

    it { should_not contain_file('/usr/local/bin/vault-bootstrap') }
    it { should_not contain_exec('vault-bootstrap') }
  end

  context 'config with alternate config file' do
    let(:params) { {
      :config_file => '/tmp/vault.hcl',
      :admins      => ['admin'],
      :server      => true,
    } }

    it { should compile.with_all_deps }

    it { should contain_file('vault config.hcl').with_path('/tmp/vault.hcl') }
  end

  context 'config with unsupported init style' do
    let(:params) { {
      :init_style => 'unsupported',
      :admins     => ['admin'],
      :server     => true,
    } }

    it { should_not compile.and_raise_error(Puppet::ParseError) }
  end

end
