#
# Cookbook Name:: redis
# Recipe:: source
# Author:: saberma
# Email:: mahb45@gmail.com
#
# Copyright 2011, shopqi.com
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

include_recipe "build-essential"

unless platform?("centos","redhat","fedora")
  include_recipe "runit"
end

redis_version = node[:redis][:version]

remote_file "/tmp/redis-#{redis_version}.tar.gz" do
  source "https://github.com/antirez/redis/tarball/#{redis_version}"
  action :create_if_missing
end

directory node[:redis][:dir] do
  owner "app"
  group "app"
  mode "0755"
end

bash "compile_redis_source" do
  cwd "/tmp"
  code <<-EOH
    tar zxf redis-#{redis_version}.tar.gz
    cd antirez-redis-*
    make
    cp -r src #{node[:redis][:dir]}
  EOH
  creates "#{node[:redis][:dir]}/redis-server"
end

runit_service "redis-server" do
  template_name "redis"
  cookbook "redis"
end

template "/etc/redis.conf" do
  notifies :restart, resources(:service => "redis-server")
end
