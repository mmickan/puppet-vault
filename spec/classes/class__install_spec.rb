require 'spec_helper'

describe 'vault', :type => :class do

  let(:facts) { {
    :operatingsystem => 'ubuntu',
    :architecture    => 'amd64',
    :path            => '/usr/bin:/bin:/usr/sbin:/sbin',
  } }

  let(:params) { {
    :admins => ['admin'],
  } }

  context 'install with default settings' do
    it { should compile.with_all_deps }

    it { should contain_file('/var/lib/vault').with_ensure('directory') }
    it { should contain_package('unzip') }
    it { should contain_user('vault') }
    it { should contain_group('vault') }
    it { should contain_file('/usr/local/bin/vault').with_mode('0555') }
  end

  context 'install with alternate backend path' do
    let(:params) { {
      :backend_path => '/tmp',
      :admins       => ['admin'],
    } }

    it { should compile.with_all_deps }

    it { should_not contain_file('/var/lib/vault') }
  end

  context 'install with non-default backend type' do
    let(:params) { {
      :backend => 'consul',
      :admins  => ['admin'],
    } }

    it { should compile.with_all_deps }

    it { should_not contain_file('/var/lib/vault') }
  end

  context 'install with alternate bin_dir' do
    let(:params) { {
      :bin_dir => '/tmp',
      :admins  => ['admin'],
    } }

    it { should compile.with_all_deps }

    it { should contain_file('/tmp/vault').with_mode('0555') }
    it { should_not contain_file('/usr/local/bin/vault') }
  end

end
