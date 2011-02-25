#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2010, Promet Solutions
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

case node[:platform]
  when "centos","redhat","fedora"
    package "openssl-devel"
  when "debian","ubuntu"
    package "libssl-dev"
end

nodejs_version = node[:nodejs][:version]

remote_file "/tmp/nodejs-#{nodejs_version}.tar.gz" do
  source "http://nodejs.org/dist/node-v#{nodejs_version}.tar.gz"
  action :create_if_missing
end

directory node[:nodejs][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

bash "compile_nodejs_source" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    tar zxf nodejs-#{nodejs_version}.tar.gz
    cd node-v#{node[:nodejs][:version]}
    ./configure --prefix=#{node[:nodejs][:dir]}
    make
    make install
  EOH
  creates "#{node[:redis][:dir]}/bin/node"
end

unless node[:instance_role]
  search(:apps, 'need_nodejs:true') do |app|
    juggernaut_path = "#{app[:deploy_to]}/current/vendor/others/juggernaut"
    execute "git submodule update --init" do
      ignore_failure true
      cwd juggernaut_path
      only_if { File.exists?(juggernaut_path) }
    end

    runit_service "nodejs-server" do
      template_name "nodejs"
      options :app_root => app[:deploy_to], :binary_path => "#{node[:nodejs][:dir]}/bin/node"
      cookbook "nodejs"
    end
  end
end
