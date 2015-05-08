include_recipe 'etcd'

# Satisfy runit dependency
include_recipe 'runit'
name = 'whichsapp'

gem_package 'bundler'

application name do

  path "/var/www/apps/#{name}"
  owner 'nobody'
  group 'nogroup'
  repository 'https://github.com/gswallow/whichsapp.git'
  revision 'master'
  migrate false  #This is false because migrations are something that should be controlled and not ran on every machine automatically.
  keep_releases 2
  environment_name 'production'

  #Remove default configurations so the templates can be dropped in and managed.
  before_symlink do

    directory "#{release_path}/log" do
      owner 'nobody'
      group 'nogroup'
      mode '0755'
      action :create
    end

    template "#{release_path}/config.yml" do
      source 'config.yml.erb'
      owner 'nobody'
      group 'nogroup'
      mode '0644'
      variables(
        :etcd_server => node['ipaddress'],
        :apps => node['whichsapp']['apps'],
        :packages => node['whichsapp']['packages'],
        :assays => node['whichsapp']['assays']
      )
    end

    execute 'bundle install' do
      command 'bundle install --deployment'
      cwd "#{release_path}"
      user 'nobody'
      group 'nogroup'
      action :run
    end
  end

  unicorn do
    bundler true
    bundle_command 'bundler'
    preload_app false
    worker_processes 2
    worker_timeout 30
    forked_user 'nobody'
    forked_group 'nogroup'
    before_fork "ENV['BUNDLE_GEMFILE'] = '/var/www/apps/#{name}/current/Gemfile'"
    stdout_path "/var/www/apps/#{name}/current/log/stdout.log"
    stderr_path "/var/www/apps/#{name}/current/log/stderr.log"
    port '9080'
  end
end
