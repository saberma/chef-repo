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
#
# tar zcf ~/Dropbox/Public/shopqi/chef-solo.tar.gz ./cookbooks

require_recipe "rvm::default"
require_recipe "rvm::ruby_192"

#fixed(ruby-debug19 need): `mkdir': Permission denied
gem_package 'linecache19'

require_recipe "postgresql::default"
require_recipe "unicorn::vagrant"
require_recipe "resque::vagrant"
#require_recipe "develop::daemon"
