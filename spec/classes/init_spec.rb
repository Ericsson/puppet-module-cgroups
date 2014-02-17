require 'spec_helper'
describe 'cgroups' do
  describe 'with default values for all parameters' do
    context 'on RedHat 6.4' do
      let(:facts) do
        { :osfamily                   => 'RedHat',
          :operatingsystemrelease     => '6.4',
          :operatingsystemmajrelease  => '6',
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
        should contain_file('cg_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/cgconfig.conf',
          'notify'  => 'Service[cgconfig_service]',
          'require' => 'Package[libcgroup]',
        })
        should contain_file('cg_conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /cgroup;
}

})
      }

      it { should_not contain_file('path_fix') }

      it {
        should contain_service('cgconfig_service').with({
          'ensure'  => 'running',
          'enable'    => 'true',
          'name'  => 'cgconfig',
          'require' => 'Package[libcgroup]',
        })
      }

    end

    context 'on RedHat < 6.4 (5.2)' do
      let(:facts) do
        { :osfamily                   => 'RedHat',
          :operatingsystemrelease     => '5.2',
          :operatingsystemmajrelease  => '5',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on RHEL 6/)
      end

    end

    context 'on RedHat > 6.4 (7.0)' do
      let(:facts) do
        { :osfamily                   => 'RedHat',
          :operatingsystemrelease     => '7.0',
          :operatingsystemmajrelease  => '7',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on RHEL 6/)
      end
    end

    context 'on Suse 11.2' do
      let(:facts) do
        { :osfamily                   => 'Suse',
          :operatingsystemrelease     => '11.2',
          :lsbmajdistrelease  => '11',
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
        should contain_file('cg_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/cgconfig.conf',
          'notify'  => 'Service[cgconfig_service]',
          'require' => 'Package[libcgroup1]',
        })
        should contain_file('cg_conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /sys/fs/cgroup;
}

})
      }

      it { should_not contain_file('path_fix') }

      it {
        should contain_service('cgconfig_service').with({
          'ensure'  => 'running',
          'enable'    => 'true',
          'name'  => 'cgconfig',
          'require' => 'Package[libcgroup1]',
        })
      }
    end

    context 'on Suse < 11.2 (11.1)' do
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.1',
          :lsbmajdistrelease  => '11',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on Suse 11.2 and upward/)
      end
    end

    context 'on Suse is > 11.2 (11.3)' do
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.3',
          :lsbmajdistrelease  => '11',
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
        should contain_file('cg_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/cgconfig.conf',
          'notify'  => 'Service[cgconfig_service]',
          'require' => 'Package[libcgroup1]',
        })
        should contain_file('cg_conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /sys/fs/cgroup;
}

})
      }

      it { should_not contain_file('path_fix') }

      it {
        should contain_service('cgconfig_service').with({
          'ensure'  => 'running',
          'enable'    => 'true',
          'name'  => 'cgconfig',
          'require' => 'Package[libcgroup1]',
        })
      }
    end
  end

  describe 'with cgconfig_content parameter specified' do
    context 'on RedHat 6.4' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :operatingsystemmajrelease  => '6',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('cg_conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /cgroup;
}

kalle is king hallelulja})
      }

      it { should_not contain_file('path_fix') }

    end

    context 'on RedHat < 6.4 (5.2)' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '5.2',
          :operatingsystemmajrelease  => '5',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on RHEL 6/)
      end

    end
    context 'on RedHat > 6.4 (7.0)' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '7.0',
          :operatingsystemmajrelease  => '7',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on RHEL 6/)
      end

    end
    context 'On Suse 11.2' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.2',
          :lsbmajdistrelease  => '11',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('cg_conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /sys/fs/cgroup;
}

kalle is king hallelulja})
      }

      it { should_not contain_file('path_fix') }

    end
    context 'on Suse < 11.2 (11.1)' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.1',
          :lsbmajdistrelease  => '11',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on Suse 11.2 and upward/)
      end
    end

    context 'on Suse > 11.2 (12.1)' do
      let(:params) { { :cgconfig_content => 'kalle is king hallelulja' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '12.1',
          :lsbmajdistrelease  => '11',
        }
      end

      it { should compile.with_all_deps }

      it {
        should contain_file('cg_conf').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT

mount {
  cpu = /sys/fs/cgroup;
}

kalle is king hallelulja})
      }

      it { should_not contain_file('path_fix') }

    end

  end

  describe 'and with user_path_fix specified' do
    context 'on RedHat < 6.4 (5.2)' do
      let(:params) { { :user_path_fix => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '5.2',
          :operatingsystemmajrelease  => '5',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on RHEL 6/)
      end
    end

    context 'on RedHat > 6.4 (7.0)' do
      let(:params) { { :user_path_fix => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '7.0',
          :operatingsystemmajrelease  => '7',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on RHEL 6/)
      end
    end

    context 'on RedHat 6.4' do
      let(:params) { { :user_path_fix => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :operatingsystemmajrelease  => '6',
        }
      end

      it { should compile.with_all_deps }

      it { should_not contain_file('path_fix') }
    end


    context 'on Suse < 11.2 (11.1)' do
      let(:params) { { :user_path_fix    => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.1',
          :lsbmajdistrelease  => '11',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('cgroups')
        }.to raise_error(Puppet::Error,/cgroups is only supported on Suse 11.2 and upward/)
      end

    end

    context 'on Suse > 11.2 (11.4)' do
      let(:params) { { :user_path_fix    => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.4',
          :lsbmajdistrelease  => '11',
        }
      it { should compile.with_all_deps }
      it {
        should contain_file('path_fix').with({
        'ensure'  => 'directory',
        'path'    => '/kalle',
        'mode'    => '0775',
        'require' => 'Service[cgconfig_service]',
        })
      }
      end
    end

    context 'On Suse 11.2' do
      let(:params) { { :user_path_fix    => '/kalle' } }
      let(:facts) do
        { :osfamily               => 'Suse',
          :operatingsystemrelease => '11.2',
          :lsbmajdistrelease  => '11',
        }
      end

      it { should compile.with_all_deps }
      it {
        should contain_file('path_fix').with({
        'ensure'  => 'directory',
        'path'    => '/kalle',
        'mode'    => '0775',
        'require' => 'Service[cgconfig_service]',
        })
      }
    end
  end
end
