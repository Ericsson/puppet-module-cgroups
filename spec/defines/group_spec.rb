require 'spec_helper'

describe 'cgroups::group' do
  let (:title) { 'test' }
  context 'when declared before the cgroups class' do
    it 'should fail' do
      should raise_error(Puppet::Error,/Must include cgroups module before declaring cgroups::group resources/)
    end
  end
end

describe 'cgroups::group' do
  
  let :pre_condition do
    'class { "cgroups": }'
  end

  let (:title) { 'user_mgw-all' }
  let(:facts) do
    { :osfamily                  => 'RedHat',
      :operatingsystemrelease    => '7.1',
      :operatingsystemmajrelease => '7',
    }
  end

  context 'when declared' do
    let (:params) { {
      :permissions => {
        'task' => {
          'uid' => 'root',
          'gid' => 'mgw-all'
        },
        'admin' => {
          'uid' => 'root',
          'gid' => 'mgw-all'
        }
      },
      :controllers => {
        'cpu' => {
          'cpuset.mems' => '0',
          'cpuset.cpus' => '0,1'
        }
      }
    }}

    it do
      should contain_file('/etc/cgconfig.d/user_mgw-all.conf').with({
        'notify' => 'Service[cgconfig]'
      })
      should contain_file('/etc/cgconfig.d/user_mgw-all.conf').with_content(
%{group user_mgw-all {
  perm {
    task  {
      uid = root;
      gid = mgw-all;
    }
    admin  {
      uid = root;
      gid = mgw-all;
    }
  }

  cpu {
    cpuset.mems = 0;
    cpuset.cpus = 0,1;
  }

}
})
    end
  end
end
