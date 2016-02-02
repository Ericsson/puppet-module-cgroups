require 'spec_helper'
describe 'cgroups' do

  tests = {
    'no params' =>
    { :test     =>  false,
      :descr    => 'with default values for all parameters',
    },
      'with cgconfig_content param ' =>
    { :test             => true,
      :descr    => 'with values for cgconfig_content parameters',
      :cgconfig_content => 'kalle is king'
    },
      'with user_path_fix param ' =>
    { :test           => true,
      :descr    => 'with values for user_path_fix parameters',
      :user_path_fix  => '/kalle',
    },
  }

  platforms = {
    'rhel6.4' =>
    { :osfamily                   => 'RedHat',
      :lsbmajdistrelease          => '6',
      :operatingsystemmajrelease  => '6',
      :operatingsystemrelease     => '6.4',
      :sup                        => true,
    },
    'rhel5.2' =>
    { :osfamily                   => 'RedHat',
      :lsbmajdistrelease          => '5',
      :operatingsystemmajrelease  => '5',
      :operatingsystemrelease     => '5.2',
      :error                      => 'cgroups is only supported on RHEL 6',
    },
    'rhel7.0' =>
    { :osfamily                   => 'RedHat',
      :lsbmajdistrelease          => '7',
      :operatingsystemmajrelease  => '7',
      :operatingsystemrelease     => '7.0',
      :error                      => 'cgroups is only supported on RHEL 6',
    },
    'Suse11.2' =>
    { :osfamily                   => 'Suse',
      :lsbmajdistrelease          => '11',
      :operatingsystemmajrelease  => '11',
      :operatingsystemrelease     => '11.2',
      :sup                        => true,
    },
    'Suse11.0' =>
    { :osfamily                   => 'Suse',
      :lsbmajdistrelease          => '11',
      :operatingsystemmajrelease  => '11',
      :operatingsystemrelease     => '11.0',
      :error                      => 'cgroups is only supported on Suse 11.2 and upward',
    },
    'Suse11.3' =>
    { :osfamily                   => 'Suse',
      :lsbmajdistrelease          => '11',
      :operatingsystemmajrelease  => '11',
      :operatingsystemrelease     => '11.3',
      :sup                        => true,
    },
    'Suse10.4' =>
    { :osfamily                   => 'Suse',
      :lsbmajdistrelease          => '10',
      :operatingsystemmajrelease  => '10',
      :operatingsystemrelease     => '10.4',
      :error                      => 'cgroups is only supported on Suse 11 (11.2 and up)',
    },
    'Suse12.0' =>
    { :osfamily                   => 'Suse',
      :lsbmajdistrelease          => '12',
      :operatingsystemmajrelease  => '12',
      :operatingsystemrelease     => '12.0',
      :error                      => 'cgroups is only supported on Suse 11 (11.2 and up)',
    },
  }

  tests.sort.each do |tk,tv|
    describe "#{tv[:descr]}" do
      platforms.sort.each do |k,v|
        describe "on #{v[:osfamily]} #{v[:operatingsystemrelease]} " do
          let(:facts) do
            { :osfamily                   => v[:osfamily],
              :lsbmajdistrelease          => v[:lsbmajdistrelease],
              :operatingsystemmajrelease  => v[:operatingsystemmajrelease],
              :operatingsystemrelease     => v[:operatingsystemrelease],
            }
          end
          if tv[:cgconfig_content]
            let(:params) { { :cgconfig_content => tv[:cgconfig_content] }}
          end
          if tv[:user_path_fix]
            let(:params) { { :user_path_fix    => tv[:user_path_fix] } }
          end

          if v[:sup]

            it { should compile.with_all_deps }

            it { should contain_class('cgroups') }

            if v[:osfamily] == 'RedHat'
              it {
                should contain_package('libcgroup').with({
                  'ensure' => 'present',
                })
              }

              if tv[:cgconfig_content]

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

kalle is king})
                }
              else

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
              end

              it {
                should contain_service('cgconfig_service').with({
                  'ensure'  => 'running',
                  'enable'    => 'true',
                  'name'  => 'cgconfig',
                  'require' => 'Package[libcgroup]',
                })
              }
            else
              it {
                should contain_package('libcgroup1').with({
                  'ensure' => 'present',
                })
              }
              if tv[:cgconfig_content]
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

kalle is king})
                }
              else

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
              end
              it {
                should contain_service('cgconfig_service').with({
                  'ensure'  => 'running',
                  'enable'    => 'true',
                  'name'  => 'cgconfig',
                  'require' => 'Package[libcgroup1]',
                })
              }

              if tv[:user_path_fix]

               it {
                  should contain_file('cgroups_path_fix').with({
                    'ensure'  => 'directory',
                    'path'    => '/kalle',
                    'mode'    => '0775',
                    'require' => 'Service[cgconfig_service]',
                  })
                }

              else
                it { should_not contain_file('path_fix') }
              end
            end

          else

            it 'should fail' do
              expect {
                should contain_class('cgroups')
              }.to raise_error(Puppet::Error,/cgroups is only supported on/)
            end

          end

        end
      end
    end
  end
end
