require 'spec_helper'

describe 'vault::ssl_certificate', :type => :define do
  let(:title) { 'test-service' }

  let(:facts) { {
    :osfamily     => 'Debian',
    :lsbdistid    => 'ubuntu',
    :architecture => 'amd64',
    :ipaddress    => '1.2.3.4',
    :path         => '/usr/bin:/bin:/usr/sbin:/sbin',
  } }

  describe 'with defaults' do
    let(:params) { {
      :host => 'host.example.com',
      :directory => '/tmp/',
    } }

    it { should compile.with_all_deps }

    it { should contain_exec('Deploy SSL certificate for test-service') }
    it { should contain_cron('Rotate SSL certificate for test-service') }
  end

  describe 'with aliases' do
    let(:params) { {
      :host => 'host.example.com',
      :aliases => ['1.2.3.4', '5.6.7.8', 'host2.example.com', 'host3.example.com'],
      :directory => '/tmp',
    } }

    it { should compile.with_all_deps }

    it { should contain_exec('Deploy SSL certificate for test-service').with_command('/usr/local/bin/deploy-ssl-certificate --domain example.com --common_name host.example.com --alt_names "host2.example.com, host3.example.com" --ip_sans "1.2.3.4, 5.6.7.8" --lease 168h --certfile /tmp/host.example.com.cert.pem --keyfile /tmp/host.example.com.key.pem') }
    it { should contain_cron('Rotate SSL certificate for test-service').with_command('env VAULT_ADDR=https://1.2.3.4:8200 /usr/local/bin/deploy-ssl-certificate --domain example.com --common_name host.example.com --alt_names "host2.example.com, host3.example.com" --ip_sans "1.2.3.4, 5.6.7.8" --lease 168h --certfile /tmp/host.example.com.cert.pem --keyfile /tmp/host.example.com.key.pem') }
  end

end
