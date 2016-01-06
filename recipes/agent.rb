whatsinstalled_server = search("node", "role:whatsinstalled AND chef_environment:#{node.chef_environment}").first

gem_package 'bundler'

directory '/opt/whatsinstalled' do
  owner 'nobody'
  group 'nogroup'
  mode '0755'
  action :create
end

git '/opt/whatsinstalled' do
  repository 'https://github.com/gswallow/whatsinstalled.git'
  revision 'master'
  action :export
  remote 'origin'
  depth 1
  user 'nobody'
  group 'nogroup'
end

execute 'bundle install' do
  command 'bundle install --deployment'
  cwd '/opt/whatsinstalled'
  user 'nobody'
  group 'nogroup'
  action :run
end

template '/opt/whatsinstalled/config.yml' do
  owner 'nobody'
  group 'nogroup'
  mode '0644'
  variables(
    :etcd_server => whatsinstalled_server['ipaddress'],
    :apps => node['whatsinstalled']['apps'],
    :packages => node['whatsinstalled']['packages'],
    :assays => node['whatsinstalled']['assays']
  )
  action :create
end

cookbook_file '/etc/init.d/whatsinstalled_agent' do
  source 'whatsinstalled_agent'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
end

service 'whatsinstalled_agent' do
  action [ :enable, :restart ]
end
