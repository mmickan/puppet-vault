require 'spec_helper_acceptance'

describe 'vault::ssl_certificate defined type' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp = <<-EOS
      class { 'vault':
        admins         => ['vagrant'],
        puppet_app_id  => 'puppet-acceptance-test-app-id',
        server         => true,
        bootstrap      => true,
        advertise_addr => '127.0.0.1',
      }
      -> vault::backend::secret::pki{ 'consul': }

      # deploy an SSL certificate/key pair
      -> vault::ssl_certificate { 'test-service':
        host      => 'host.node.consul',
        domain    => 'consul',
        directory => '/tmp',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :future_parser => true, :catch_failures => true)
      apply_manifest(pp, :future_parser => true, :catch_changes => true)
    end

    describe file('/tmp/host.node.consul.cert.pem') do
      it { should be_mode 444 }
      its(:content) { should match /BEGIN CERTIFICATE/ }
    end

    describe file('/tmp/host.node.consul.key.pem') do
      it { should be_mode 400 }
      its(:content) { should match /BEGIN RSA PRIVATE KEY/ }
    end

  end

end
