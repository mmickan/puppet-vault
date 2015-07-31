require 'spec_helper_acceptance'

describe 'vault::ssl_certificate defined type' do

  context 'default parameters' do

    it 'shuold work with no errors' do
      pp = <<-EOS
      class { 'vault':
        admins => ['vagrant'],
      }
      ->
      exec { 'Download Vagrant insecure key':
        command => 'curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant > /home/vagrant/.ssh/id_rsa',
        path    => $::path,
        creates => '/home/vagrant/.ssh/id_rsa',
      }
      ->
      exec { 'Decrypt root token':
        command => 'cat /home/vagrant/vault_initial_root_token | openssl rsautl -decrypt -inkey /home/vagrant/.ssh/id_rsa > /tmp/vault_initial_root_token',
        path    => $::path,
        creates => '/tmp/vault_initial_root_token',
      }
      ->
      exec { 'Authorise deploy-ssl-certificate app':
        command     => 'vault-auth-app --token=@/tmp/vault_initial_root_token --enable-backend --app-name=deploy-ssl-certificate --app-id=@deploy-ssl-certificate --roles=deploy-ssl-certificate',
        path        => "/usr/local/bin:${::path}",
        refreshonly => true,
        require     => File['/usr/local/bin/deploy-ssl-certificate'],
        subscribe   => File['/usr/local/bin/vault-auth-app'],
      }
      ->
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
