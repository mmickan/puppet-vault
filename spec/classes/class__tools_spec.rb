require 'spec_helper'

describe 'vault::tools', :type => :class do

  context 'with defaults' do

    it { should compile.with_all_deps }

    it { should contain_file('/usr/local/bin/deploy-ssl-certificate') }
  end

end
