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
include_recipe "nodejs"

app_root = "/vagrant"
juggernaut_path = "#{app_root}/vendor/others/juggernaut"
execute "git submodule update --init" do
  cwd juggernaut_path
  only_if { File.exists?(juggernaut_path) }
end

runit_service "nodejs-server" do
  template_name "vagrant"
  options :app_root => app_root, :binary_path => "#{node[:nodejs][:dir]}/bin/node"
  cookbook "nodejs"
end
