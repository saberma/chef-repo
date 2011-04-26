#
# Cookbook Name:: develop
# Recipe:: default
#
# Copyright 2011, ShopQi, Inc.
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

postgresql_version = node[:postgresql][:version]
config_dir = node[:postgresql][:config_dir]
data_dir = node[:postgresql][:data_dir]
sock_dir = node[:postgresql][:sock_dir]
bin_dir = node[:postgresql][:bin_dir]

remote_file "/tmp/postgresql-#{postgresql_version}.tar.bz2" do
  source "https://github.com/downloads/saberma/shopqi/postgresql-#{postgresql_version}.tar.bz2"
  action :create_if_missing
  not_if {File.exists?("#{node[:postgresql][:binary]}")}
end

bash "compile_postgresql_source" do
  user 'root'
  cwd "/tmp"
  code <<-EOH
    tar xjf postgresql-#{postgresql_version}.tar.bz2
    cd postgresql-#{postgresql_version} && ./configure
    make && make install
  EOH
  creates node[:postgresql][:binary]
end

user "postgres"

[config_dir, data_dir].each do |dir|
  directory dir do
    owner "postgres"
    group "postgres"
    recursive true
  end
end

runit_service "postgresql" do
  template_name "postgres"
  cookbook "postgresql"
  options :config_dir => config_dir, :sock_dir => sock_dir
end

service "postgresql" do
  supports :status => true, :restart => true, :reload => true
  action :nothing
end

template "#{config_dir}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, resources(:service => "postgresql")
end

template "#{config_dir}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, resources(:service => "postgresql")
end

#http://www.postgresql.org/docs/8.3/static/multibyte.html
bash "init postgresql data" do
  user 'postgres'
  code <<-EOH
    #{bin_dir}/initdb -D #{data_dir} -E UTF8
  EOH
  only_if { Dir.glob("#{data_dir}/*").empty? }
end

#只安装客户端的步骤
#http://www.postgresql.org/docs/9.0/static/install-procedure.html [Client-only installation]
#wget ftp://ftp2.cn.postgresql.org/postgresql/source/v9.0.3/postgresql-9.0.3.tar.bz2 
#tar xjf postgresql-9.0.3.tar.bz2
#d postgresql-9.0.3
#./configure
#make
#make -C src/bin install
#make -C src/include install
#make -C src/interfaces install
#make -C doc install
