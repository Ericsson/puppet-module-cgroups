require 'spec_helper'
describe 'cgroups' do
  let(:facts) do
    {
      :operatingsystemmajrelease => '7',
      :operatingsystemrelease    => '7.2',
      :osfamily                  => 'RedHat',
    }
  end

  platforms = {
    'RedHat' => {
      :operatingsystemmajrelease => '7',
      :operatingsystemrelease    => '7.2',
      :osfamily                  => 'RedHat',
      :package_name              => 'libcgroup',
    },
    'Suse' => {
      :operatingsystemmajrelease => nil, # not available on Suse
      :operatingsystemrelease    => '11.2',
      :osfamily                  => 'Suse',
      :package_name              => 'libcgroup1',
    },
  }

  describe 'with defaults for all parameters' do
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
    END

    it { should compile.with_all_deps }
    it { should contain_class('cgroups') }
    it { should_not contain_file('cgroups_path_fix') }
    it { should have_cgroups__group_resource_count(0) }
    it { should contain_package('libcgroup').with_ensure('present') }
    it do
      should contain_file('/etc/cgconfig.conf').with({
        'ensure'  => 'file',
        'notify'  => ['Service[cgconfig]', 'Service[cgred]'],
        'require' => 'Package[libcgroup]',
        'content' => content,
      })
    end

    it do
      should contain_file('/etc/cgrules.conf').with({
        'ensure'  => 'file',
        'notify'  => ['Service[cgconfig]', 'Service[cgred]'],
        'require' => 'Package[libcgroup]',
        'content' => content,
      })
    end

    it do
      should contain_service('cgconfig').with({
        'ensure'  => 'running',
        'enable'  => 'true',
        'require' => 'Package[libcgroup]',
      })
    end

    it do
      should contain_service('cgred').with({
        'ensure'  => 'stopped',
        'enable'  => 'false',
        'require' => 'Package[libcgroup]',
      })
    end
  end

  describe 'with config_file_path set to valid string </specific/path>' do
    let(:params) { { :config_file_path => '/specific/path' } }

    it { should contain_file('/specific/path') }
  end

  describe 'with rules_file_path set to valid string </specific/path>' do
    let(:params) { { :rules_file_path => '/specific/path' } }

    it { should contain_file('/specific/path') }
  end

  describe 'with service_name set to valid string <other_name>' do
    # $user_path_fix on SLES >= 11.2 utilizes $service_name too
    let(:facts) do
      {
        :operatingsystemrelease => '11.2',
        :osfamily               => 'Suse',
      }
    end
    let(:params) do
      {
        :service_name  => 'other_name',
        :user_path_fix => '/specific/path',
      }
    end

    it { should contain_file('cgroups_path_fix').with_require(['Service[other_name]', 'Service[cgred]']) }
    it { should contain_file('/etc/cgconfig.conf').with_notify(['Service[other_name]', 'Service[cgred]']) }
    it { should contain_service('other_name') }
  end

  describe 'with rules_service_name set to valid string <rules_other_name>' do
    let(:facts) do
      {
        :operatingsystemrelease => '11.2',
        :osfamily               => 'Suse',
      }
    end
    let(:params) do
      {
        :rules_service_name  => 'rules_other_name',
        :user_path_fix => '/specific/path',
      }
    end

    it { should contain_file('cgroups_path_fix').with_require(['Service[cgconfig]', 'Service[rules_other_name]']) }
    it { should contain_file('/etc/cgconfig.conf').with_notify(['Service[cgconfig]', 'Service[rules_other_name]']) }
    it { should contain_service('rules_other_name') }
  end

  describe 'with rules service enabled and running' do
    let(:facts) do
      {
        :operatingsystemrelease => '11.2',
        :osfamily               => 'Suse',
      }
    end
    let(:params) do
      {
        :rules_service_enable  => true,
        :rules_service_ensure => 'running',
      }
    end

    it { should contain_service('cgred').with({
      'ensure'  => 'running',
      'enable'  => 'true',
    })}
  end

  platforms.sort.each do |platform, v|
    describe "with package_name default value on osfamily <#{platform}>" do
      let(:facts) do
        {
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :operatingsystemrelease    => v[:operatingsystemrelease],
          :osfamily                  => v[:osfamily],
        }
      end

      it { should contain_package(v[:package_name]) }
      it { should contain_file('/etc/cgconfig.conf').with_require("Package[#{v[:package_name]}]") }
      it { should contain_service('cgconfig').with_require("Package[#{v[:package_name]}]") }
    end
  end

  describe 'with package_name set to valid string <specific_package>' do
    let(:params) { { :package_name => 'specific_package' } }

    it { should contain_package('specific_package') }
    it { should contain_file('/etc/cgconfig.conf').with_require('Package[specific_package]') }
    it { should contain_service('cgconfig').with_require('Package[specific_package]') }
  end

  describe 'with package_name set to valid array %w(specific packages)' do
    let(:params) { { :package_name => %w(specific packages) } }

    it { should contain_package('specific') }
    it { should contain_package('packages') }
    it { should contain_file('/etc/cgconfig.conf').with_require(['Package[specific]', 'Package[packages]']) }
    it { should contain_service('cgconfig').with_require(['Package[specific]', 'Package[packages]']) }
  end

  describe 'with cgconfig_content set to valid string <specific content>' do
    let(:params) { { :cgconfig_content => 'specific content' } }
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |specific content
    END

    it { should contain_file('/etc/cgconfig.conf').with_content(content) }
  end

  describe 'with user_path_fix set to valid string </specific/path> on RedHat' do
    let(:params) { { :user_path_fix => '/specific/path' } }

    it { should_not contain_file('cgroups_path_fix') }
  end

  describe 'with user_path_fix set to valid string </specific/path> on SLES 11.2' do
    let(:facts) do
      {
        :operatingsystemrelease    => '11.2',
        :osfamily                  => 'Suse',
      }
    end
    let(:params) { { :user_path_fix => '/specific/path' } }

    it { should contain_file('cgroups_path_fix').with_require(['Service[cgconfig]', 'Service[cgred]']) }
  end

  describe 'with mounts set to valid hash { spec => /test, cpu => /cgroups }' do
    let(:params) { { :mounts => { 'spec' => '/test', 'cpu' => '/cgroup' } } }
    # test includes alphabetical sorting of values in the template
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |mount {
      |  cpu = /cgroup;
      |  spec = /test;
      |}
    END

    it { should contain_file('/etc/cgconfig.conf').with_content(content) }
  end

  describe 'with groups set to valid hash' do
    let(:params) do
      {
        :groups => {
          'user/mgw-all' => {
            'permissions' => {
              'task' => {
                'uid' => 'root',
                'gid' => 'mgw-all'
              },
              'admin' => {
                'uid' => 'root',
                'gid' => 'mgw-all'
              }
            },
            'controllers' => {
              'cpu' => {
                'cpuset.mems' => '0',
                'cpuset.cpus' => '0,1'
              }
            }
          },
          'spec/test' => {
            'permissions' => {
              'spec' => {
                'uid' => 'root',
                'gid' => 'test'
              }
            },
          },
        },
      }
    end

    it { should have_cgroups__group_resource_count(2) }
    it do
      should contain_cgroups__group('user/mgw-all').with({
        'permissions' => {
          'task' => {
            'uid' => 'root',
            'gid' => 'mgw-all'
          },
          'admin' => {
            'uid' => 'root',
            'gid' => 'mgw-all'
          }
        },
        'controllers' => {
          'cpu' => {
            'cpuset.mems' => '0',
            'cpuset.cpus' => '0,1'
          }
        }
      })
    end

    it do
      should contain_cgroups__group('spec/test').with({
        'permissions' => {
          'spec' => {
            'uid' => 'root',
            'gid' => 'test'
          },
        },
      })
    end
  end

  describe 'with rules set to valid hash' do
    let(:params) {{
      :rules => {
        '@template1' => {
          'controllers' => 'cpu,cpuacct,memory',
          'destination' => 'template1/%u',
        },
        '@template2' => {
          'controllers' => 'cpu,cpuacct,memory',
          'destination' => 'template2/%u',
        }
      }
    }}

    # test includes alphabetical sorting of values in the template
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |@template1\tcpu,cpuacct,memory\ttemplate1/%u
      |@template2\tcpu,cpuacct,memory\ttemplate2/%u
    END

    it { should contain_file('/etc/cgrules.conf').with_content(content) }
  end

  %w(5 8).each do |release|
    context "on EL #{release}" do
      let(:facts) do
        {
          :operatingsystemmajrelease => release,
          :operatingsystemrelease    => "#{release}.0",
          :osfamily                  => 'RedHat',
        }
      end

      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /cgroups is only supported on EL 6 and 7/)
      end
    end
  end

  %w(10 11.0 11.1 12).each do |release|
    context "on Suse #{release}" do
      let(:facts) do
        {
          :operatingsystemrelease => release,
          :osfamily               => 'Suse',
        }
      end

      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /cgroups is only supported on Suse 11 with SP2 and up/)
      end
    end
  end

  context 'on unknown OS WeirdOS' do
    let(:facts) { { :osfamily => 'WeirdOS' } }

    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /cgroups is not supported on this platform/)
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :operatingsystemmajrelease => '6',
        :operatingsystemrelease    => '6.4',
        :osfamily                  => 'RedHat',
      }
    end
    let(:mandatory_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'absolute_path' => {
        :name    => %w(config_file_path user_path_fix),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'array/string' => {
        :name    => %w(package_name),
        :valid   => ['string', %w(array)],
        :invalid => [{ 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string or an array',
      },
      'hash' => {
        :name    => %w(mounts groups),
        :valid   => ['f' => { 'permissions' => { '2' => { '4' => '2' } } }],
        :invalid => ['string', %w(array), 3, 2.42, true, false, nil],
        :message => 'is not a Hash',
      },
      'string' => {
        :name    => %w(service_name cgconfig_content),
        :valid   => %w(string),
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
