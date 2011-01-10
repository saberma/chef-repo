#
# Cookbook Name:: rails3-deploy
# Recipe:: default
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

search(:apps) do |app|

  ## First, install any application specific packages
  if app['packages']
    app['packages'].each do |pkg,ver|
      package pkg do
        action :install
        version ver if ver && ver.length > 0
      end
    end
  end

  ## Next, install any application specific gems
  if app['gems']
    app['gems'].each do |gem,ver|
      gem_package gem do
        action :install
        version ver if ver && ver.length > 0
      end
    end
  end

  directory app['deploy_to'] do
    owner app['owner']
    group app['group']
    mode '0755'
    recursive true
  end

  directory "#{app['deploy_to']}/shared" do
    owner app['owner']
    group app['group']
    mode '0755'
    recursive true
  end

  %w{ log pids system }.each do |dir|

    directory "#{app['deploy_to']}/shared/#{dir}" do
      owner app['owner']
      group app['group']
      mode '0666'
      recursive true
    end

  end

  ## Then, deploy
  deploy_revision app['id'] do
    revision app['revision'][node.app_environment]
    repository app['repository']
    user app['owner']
    group app['group']
    deploy_to app['deploy_to']
    environment 'RAILS_ENV' => node.app_environment, 'MONGODB_URI' => app['mongodb_uri']
    action app['force'][node.app_environment] ? :force_deploy : :deploy

    before_migrate do
      execute "git submodule update --init" do
        ignore_failure true
        cwd release_path
      end
      if app['gems'].has_key?('bundler')
        execute "bundle install" do
          ignore_failure true
          cwd release_path
        end
      end
    end

    if app['migrate'][node.app_environment] && node[:apps][app['id']][node.app_environment][:run_migrations]
      migrate true
      migration_command app['migration_command'] || "rake db:migrate"
    else
      migrate false
    end
  end

end
