whichsapp_server = search("node", "role:whichsapp AND chef_environment:#{node.chef_environment}").first

gem_package 'bundler'

directory '/opt/whichsapp' do
  owner 'nobody'
  group 'nogroup'
  mode '0755'
  action :create
end

git '/opt/whichsapp' do
  repository 'https://github.com/gswallow/whichsapp.git'
  revision 'master'
  action :export
  remote 'origin'
  depth 1
  user 'nobody'
  group 'nogroup'
end

execute 'bundle install' do
  command 'bundle install --deployment'
  cwd '/opt/whichsapp'
  user 'nobody'
  group 'nogroup'
  action :run
end

template '/opt/whichsapp/config.yml' do
  owner 'nobody'
  group 'nogroup'
  mode '0644'
  variables(
    :etcd_server => whichsapp_server['ipaddress'],
    :apps => node['whichsapp']['apps'],
    :packages => node['whichsapp']['packages'],
    :assays => node['whichsapp']['assays']
  )
  action :create
end

cookbook_file '/etc/init.d/whichsapp_agent' do
  source 'whichsapp_agent'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
end

service 'whichsapp_agent' do
  action [ :enable, :restart ]
end
