require 'spec_helper'
describe 'cgroups' do
  describe 'with default values for all parameters' do
    context 'on RedHat 6.4' do
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '6.4',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }

      it { should contain_class('cgroups') }

      it {
        should contain_package('libcgroup').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_file('/etc/cgconfig.conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/cgconfig.conf',
          'notify'  => 'Service[cgconfig]',
          'require' => 'Package[libcgroup]',
        })
        should contain_file('/etc/cgconfig.conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT


})
      }

      it { should_not contain_file('cgroups_path_fix') }

      it {
        should contain_service('cgconfig').with({
          'ensure'  => 'running',
          'enable'  => 'true',
          'require' => 'Package[libcgroup]',
        })
      }

    end


    context 'on Suse 11.2' do
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.2',
          :lsbmajdistrelease      => '11',
        }
      end

      it { should compile.with_all_deps }

      it { should contain_class('cgroups') }

      it {
        should contain_package('libcgroup1').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_file('/etc/cgconfig.conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/cgconfig.conf',
          'notify'  => 'Service[cgconfig]',
          'require' => 'Package[libcgroup1]',
        })
      }

      it { should_not contain_file('cgroups_path_fix') }

      it {
        should contain_service('cgconfig').with({
          'ensure'  => 'running',
          'enable'    => 'true',
          'require' => 'Package[libcgroup1]',
        })
      }
    end

    context 'on Suse < 11.2 (11.1)' do
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.1',
          :lsbmajdistrelease      => '11',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on Suse 11.2 and up./)
      end
    end

    context 'on Suse is > 11.2 (11.3)' do
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.3',
          :lsbmajdistrelease      => '11',
        }
      end

      it { should compile.with_all_deps }

      it { should contain_class('cgroups') }

      it {
        should contain_package('libcgroup1').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_file('/etc/cgconfig.conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/cgconfig.conf',
          'notify'  => 'Service[cgconfig]',
          'require' => 'Package[libcgroup1]',
        })
      }

      it { should_not contain_file('cgroups_path_fix') }

      it {
        should contain_service('cgconfig').with({
          'ensure'  => 'running',
          'enable'    => 'true',
          'require' => 'Package[libcgroup1]',
        })
      }
    end
  end

  describe 'with cgconfig_content parameter specified' do
    context 'on RedHat 6.4' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '6.4',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }


      it { should_not contain_file('cgroups_path_fix') }
    end

    context 'On Suse 11.2' do
      let(:params) { 
        { 
          :cgconfig_content => 'kalle is king hallelulja',
          :mounts => { 'cpu' => '/sys/fs/cgroup' }
        } 
      }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.2',
          :lsbmajdistrelease      => '11',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('/etc/cgconfig.conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /sys/fs/cgroup;
}

kalle is king hallelulja})
      }

      it { should_not contain_file('cgroups_path_fix') }

    end

    context 'on Suse > 11.2 (12.1)' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '12.1',
          :lsbmajdistrelease      => '11',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('/etc/cgconfig.conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT


kalle is king hallelulja})
      }

      it { should_not contain_file('cgroups_path_fix') }
    end
  end

  describe 'and with user_path_fix specified' do
    context 'on RedHat 6.4' do
      let(:params) { { :user_path_fix => '/kalle' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '6.4',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }

      it { should_not contain_file('cgroups_path_fix') }
    end

    context 'On Suse 11.2' do
      let(:params) { { :user_path_fix => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.2',
          :lsbmajdistrelease      => '11',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('cgroups_path_fix').with({
        'ensure'  => 'directory',
        'path'    => '/kalle',
        'mode'    => '0775',
        'require' => 'Service[cgconfig]',
        })
      }
    end
  end

  describe 'with config_file_path parameter specified' do
    context 'as a valid path' do
      let(:params) { { :config_file_path => '/usr/local/etc/cgconfig.conf' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('/usr/local/etc/cgconfig.conf').with({
          'ensure'  => 'file',
          'notify'  => 'Service[cgconfig]',
          'require' => 'Package[libcgroup]',
        })
      }
    end

    context 'as an invalid path' do
      let(:params) { { :config_file_path => 'invalid/path' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'with service_name parameter specified' do
    context 'as a string' do
      let(:params) { { :service_name => 'mycgconfig' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_service('mycgconfig').with({
          'ensure'  => 'running',
          'enable'  => 'true',
          'require' => 'Package[libcgroup]',
        })
      }
    end

    context 'as an invalid type' do
      let(:params) { { :service_name => ['invalid','type'] } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups::service_name must be a string./)
      end
    end
  end

  describe 'with package_name parameter specified' do
    context 'as a string' do
      let(:params) { { :package_name => 'mylibcgroup' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_package('mylibcgroup').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_file('/etc/cgconfig.conf').with({
          'require' => 'Package[mylibcgroup]',
        })
      }

      it {
        should contain_service('cgconfig').with({
          'require' => 'Package[mylibcgroup]',
        })
      }
    end

    context 'as an array' do
      let(:params) { { :package_name => ['cgrouptools','libcgroup'] } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_package('cgrouptools').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_package('libcgroup').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_file('/etc/cgconfig.conf').with({
          'require' => [ 'Package[cgrouptools]', 'Package[libcgroup]' ],
        })
      }

      it {
        should contain_service('cgconfig').with({
          'require' => [ 'Package[cgrouptools]', 'Package[libcgroup]' ],
        })
      }
    end

    context 'as an invalid type' do
      let(:params) { { :package_name => true } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups::package_name must be a string or an array./)
      end
    end
  end
end
