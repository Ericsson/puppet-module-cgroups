require 'spec_helper'


describe 'cgroups::group' do
  
  let (:title) { 'user/mgw-all' }
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
      should contain_file('/etc/cgconfig.d/user-mgw-all.conf').with({
        'notify' => 'Service[cgconfig]'
      })
      should contain_file('/etc/cgconfig.d/user-mgw-all.conf').with_content(
%{group user/mgw-all {
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
