require_recipe "resque"

gem_package 'bundler' do
  action :install
end

app_root = "/vagrant"

["git submodule update", "bundle install", "rake db:seed", "rake db:migrate"].each do |cmd|
  execute cmd do
    ignore_failure true
    cwd app_root
  end
end

config = Mash.new({
  :pid_path => "/tmp/unicorn.pid",
  :worker_count => 2,
  :time_out => node[:unicorn][:timeout],
  :socket_path => "/tmp/unicorn-vagrant.sock",
  :backlog_limit => 1,
  :master_bind_address => '0.0.0.0',
  :master_bind_port => "37000",
  :worker_listeners => true,
  :worker_bind_address => '127.0.0.1',
  :worker_bind_base_port => "37001",
  :debug => false,
  :binary_path => "#{node[:languages][:ruby][:ruby_bin]} #{node[:languages][:ruby][:gems_dir]}/bin/unicorn_rails",
  :env => :development,
  :app_root => app_root,
  :enable => true,
  :config_path => "/tmp/unicorn.conf.rb",
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

service "unicorn-vagrant" do
  action [:enable, :start]
end
