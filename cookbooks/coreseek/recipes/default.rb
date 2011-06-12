#
# Cookbook Name:: coreseek
# Recipe:: default
#
# Copyright 2011, saberma <mahb45@gmail.com>
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
# http://www.coreseek.cn/products/products-install/install_on_bsd_linux/

include_recipe "build-essential"
#include_recipe "mysql::client" if node[:coreseek][:use_mysql]
#include_recipe "postgresql::default" if node[:coreseek][:use_postgres]

#./bootstrap: 1: libtoolize: not found
package 'libtool'

coreseek_version = node[:coreseek][:version]
mmseg_install_path = "#{node[:coreseek][:mmseg_install_path]}"
bin_search = "#{node[:coreseek][:install_path]}/bin/search"

remote_file "/tmp/coreseek-#{coreseek_version}.tar.gz" do
  source "#{node[:coreseek][:url]}"
  not_if { ::File.exists?("/tmp/coreseek-#{coreseek_version}.tar.gz") }
end

execute "Extract CoreSeek source" do
  cwd "/tmp"
  command "tar -zxvf /tmp/coreseek-#{coreseek_version}.tar.gz"
  not_if { ::File.exists?(bin_search) }
end

bash "compile mmseg" do
  cwd "/tmp/coreseek-#{coreseek_version}/mmseg-#{coreseek_version}"
  user "root"
  code <<-EOF
    ACLOCAL_FLAGS="-I /usr/share/aclocal" ./bootstrap
    ./configure --prefix=#{mmseg_install_path}
    make && make install
  EOF
  not_if { ::File.exists?(bin_search) }
end

bash "compile coreseek" do
  cwd "/tmp/coreseek-#{coreseek_version}/csft-#{coreseek_version}"
  user "root"
  code <<-EOF
    sh buildconf.sh
    ./configure #{node[:coreseek][:configure_flags].join(" ")}
    make
    make install
  EOF
  not_if { ::File.exists?(bin_search) }
end
