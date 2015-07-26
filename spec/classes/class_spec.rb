require 'spec_helper'

describe 'vault', :type => :class do

  let(:facts) { {
    :osfamily     => 'Debian',
    :lsbdistid    => 'ubuntu',
    :architecture => 'amd64',
    :path         => '/usr/bin:/bin:/usr/sbin:/sbin',
  } }

  context 'with default settings' do
    it { should_not compile.and_raise_error(Puppet::ParseError) }
  end

  context 'with admins' do
    let(:params) { {
      :admins => ['admin'],
    } }

    it { should compile.with_all_deps }

    it { should contain_class('vault::install').that_comes_before('Class[vault::config]') }
    it { should contain_class('vault::config') }
    it { should contain_class('vault::service').that_subscribes_to('Class[vault::config]') }

    it { should_not contain_class('vault::debug') }
  end

  context 'with optional features' do
    let(:params) { {
      :debug  => true,
      :admins => ['admin'],
    } }

    it { should compile.with_all_deps }

    it { should contain_class('vault::debug') }
  end

end
