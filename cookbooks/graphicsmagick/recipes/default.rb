#
# Cookbook Name:: graphicsmagick
# Recipe:: default
#
# Copyright 2011, ShopQi, Inc.
#
# All rights reserved - Do Not Redistribute
#
include_recipe "build-essential"

gm_version = node[:gm][:version]

remote_file "/tmp/GraphicsMagick-#{gm_version}.tar.gz" do
  source "http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/#{gm_version}/GraphicsMagick-#{gm_version}.tar.gz/download"
  action :create_if_missing
  not_if "#{node[:gm][:src_binary]}"
end

bash "compile_gm_source" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    tar zxf GraphicsMagick-#{gm_version}.tar.gz
    cd GraphicsMagick-#{gm_version} && ./configure
    make && make install
  EOH
  creates node[:gm][:binary]
end
