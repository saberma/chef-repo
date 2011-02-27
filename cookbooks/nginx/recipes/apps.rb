#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2009, Opscode, Inc.
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
search(:apps) do |app|
  name = app[:id]
  port = (node.app_environment.to_sym == :production) ? 80 : 3000

  template "#{node[:nginx][:dir]}/sites-available/#{name}" do
    source "unicorn-site.erb"
    owner "root"
    group "root"
    mode 0644
    variables :name => name, :port => port, :socket_path => "/tmp/unicorn-#{name}.sock", :app_root => "/srv/#{name}"
    notifies :reload, resources(:service => "nginx")
  end

  nginx_site name do
    enable true
  end
end
