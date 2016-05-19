require 'spec_helper'

describe 'vault', :type => :class do
  SUPPORTED.each do |os|
    describe "on supported os #{os['name']}-#{os['rel']}" do
      let(:facts) do
        {
          :architecture => 'amd64',
          :osfamily => os['fam'],
          :operatingsystem => os['name'],
          :operatingsystemrelease => os['rel'],
          :path => '/usr/bin:/bin:/usr/sbin:/sbin',
        }
      end

      context 'with debug enabled' do
        let(:params) { {
          :debug => true,
          :admins => ['admin'],
        } }

        it { should compile.with_all_deps }

        it { should contain_file('/var/lib/puppet/debug/vault') }
      end

      context 'with custom debug directory' do
        let(:params) { {
          :debug     => true,
          :debug_dir => '/tmp',
          :admins    => ['admin'],
        } }

        it { should compile.with_all_deps }

        it { should contain_file('/tmp/vault') }
      end

      context 'with debug disabled' do
        let(:params) { {
          :admins => ['admin'],
        } }

        it { should compile.with_all_deps }

        it { should_not contain_file('/var/lib/puppet/debug/vault') }
      end

    end
  end
end
