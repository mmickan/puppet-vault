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
      ->

      # Allow Puppet to configure the PKI secret backend for the *.consul
      # domain, and then configure it
      exec { 'Authorise puppet':
        command => 'vault-auth-app --app-id=puppet-acceptance-test-app-id --enable-backend -- puppet puppet-acceptance-test-app-id puppet,configure-pki-consul && touch /tmp/puppet_app_authorised',
        creates => '/tmp/puppet_app_authorised',
        path    => "/usr/local/bin:${::path}",
        require => File['/usr/local/bin/vault-auth-app'],
      }
      ->
      vault::policy { 'configure-pki-consul':
        policy => {
          'pki-consul/config/ca' => 'sudo',
          'secret/ssl/*'         => 'read',
          'pki-consul/*'         => 'write',
        }
      }
      ->
      vault::backend::secret::pki{ 'consul': }
      ->

      # Allow the deploy-ssl-certificate script to issue certificates in the
      # *.consul domain
      exec { 'Authorise deploy-ssl-certificate app':
        command     => 'vault-auth-app --app-id=puppet-acceptance-test-app-id --enable-backend -- deploy-ssl-certificate @deploy-ssl-certificate deploy-ssl-certificate && touch /tmp/deploy-ssl-certificate_app_authorised',
        creates     => '/tmp/deploy-ssl-certificate_app_authorised',
        path        => "/usr/local/bin:${::path}",
        require     => [
          File['/usr/local/bin/deploy-ssl-certificate'],
          File['/usr/local/bin/vault-auth-app'],
        ],
      }
      ->
      vault::policy { 'deploy-ssl-certificate':
        policy => { 'pki-consul/issue/consul' => 'write' }
      }
      ->

      # Finally, deploy an SSL certificate/key pair
      vault::ssl_certificate { 'test-service':
        host      => 'host.node.consul',
        domain    => 'consul',
        directory => '/tmp',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :future_parser => true, :catch_failures => true)
      apply_manifest(pp, :future_parser => true, :catch_changes => true)
    end

  end

end
