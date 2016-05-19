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

      context 'service with server enabled' do
        let(:params) { {
          :admins => ['admin'],
          :server => true,
        } }

        it { should compile.with_all_deps }

        it { should contain_service('vault').with_ensure('running') }
      end

      context 'service without server enabled' do
        let(:params) { {
          :admins  => ['admin'],
          :server  => false,
        } }

        it { should compile.with_all_deps }

        it { should_not contain_service('vault') }
      end

    end
  end
end
