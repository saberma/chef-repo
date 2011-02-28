#
# Cookbook Name:: mongodb
# Recipe:: source
#
# Author:: Gerhard Lazu (<gerhard.lazu@papercavalier.com>)
#
# Copyright 2010, Paper Cavalier, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory node[:mongodb][:datadir] do
  owner "mongodb"
  group "mongodb"
  mode 0755
  recursive true
end

file node[:mongodb][:logfile] do
  owner "mongodb"
  group "mongodb"
  mode 0644
  action :create_if_missing
  backup false
end

template node[:mongodb][:config] do
  source "mongodb.conf.erb"
  owner "mongodb"
  group "mongodb"
  mode 0644
  backup false
end

template "/etc/init.d/mongodb" do
  source "mongodb.init.erb"
  mode 0755
  backup false
end

#https://gist.github.com/801739
bash "repair mongodb after a crash" do
  environment "HOME"=>"/root" 

  lock_file = File.join(node[:mongodb][:datadir],'mongod.lock')

  code <<-EOH
    set -e
    rm #{lock_file}
    sudo -u mongodb #{node[:mongodb][:dir]}/bin/mongod --dbpath=#{node[:mongodb][:datadir]} --repair
    /etc/init.d/mongodb start
  EOH

  not_if { `ps -A -o command | grep "[m]ongo"`.include? node[:mongodb][:version] }
  only_if { ::FileTest.exists?(lock_file) }
end

service "mongodb" do
  supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:template => node[:mongodb][:config])
  subscribes :restart, resources(:template => "/etc/init.d/mongodb")
end

cookbook_file "/etc/logrotate.d/mongodb" do
  source "logrotate"
  cookbook "mongodb"
  owner "mongodb"
  group "mongodb"
  mode "0644"
end
