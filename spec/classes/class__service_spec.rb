require 'spec_helper'

describe 'vault', :type => :class do

  let(:facts) { {
    :architecture => 'amd64',
    :path         => '/usr/bin:/bin:/usr/sbin:/sbin',
  } }

  let(:params) { {
    :admins => ['admin'],
  } }

  context 'service with default settings' do
    it { should compile.with_all_deps }

    it { should contain_service('vault').with_ensure('running') }
  end

  context 'service without managed_service' do
    let(:params) { {
      :manage_service => false,
      :admins         => ['admin'],
    } }

    it { should compile.with_all_deps }

    it { should_not contain_service('vault') }
  end

end
