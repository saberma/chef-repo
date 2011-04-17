#pg gem need it
package "libpq-dev"

require_recipe "unicorn"

#for rmagick, optipng for css_sprite gem.
#["imagemagick", "libmagickcore-dev", "libmagickwand-dev", "optipng"].each do |pkg|
#  package pkg do
#    options '--force-yes'
#    action :install
#  end
#end

gem_package 'bundler' do
  action :install
end

app_root = "/vagrant"

#install gems in vendor/bundle
#http://gembundler.com/bundle_install.html
["git submodule update --init", "bundle install --path vendor/bundle", "rake db:migrate"].each do |cmd|
  execute cmd do
    #ignore_failure true
    cwd app_root
  end
end

config = Mash.new({
  :pid_path => "/tmp/unicorn.pid",
  :worker_count => 1,
  :time_out => node[:unicorn][:timeout],
  :socket_path => "/tmp/unicorn-vagrant.sock",
  :backlog_limit => 1,
  :master_bind_address => '0.0.0.0',
  :master_bind_port => "3000",
  :worker_listeners => true,
  :worker_bind_address => '127.0.0.1',
  :worker_bind_base_port => "3001",
  :debug => false,
  :binary_path => "#{node[:languages][:ruby][:ruby_bin]} #{node[:languages][:ruby][:gems_dir]}/bin/unicorn_rails",
  :env => :development,
  :app_root => app_root,
  :enable => true,
  :config_path => "#{app_root}/config/unicorn.conf.rb",
})

template config[:config_path] do
  mode '644'
  source "unicorn.conf.erb"
  variables config
end

runit_service "unicorn-vagrant" do
  template_name "vagrant"
  cookbook "unicorn"
  options config
end
