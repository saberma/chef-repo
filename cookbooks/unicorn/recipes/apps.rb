counter = 0

search(:apps) do |app|
  name = app[:id]

  app_root = "/srv/#{name}"
  defaults = Mash.new({
    :pid_path => "#{app_root}/shared/pids/unicorn.pid",
    :worker_count => node[:unicorn][:worker_count],
    :timeout => node[:unicorn][:timeout],
    :socket_path => "/tmp/unicorn/#{name}.sock",
    :backlog_limit => 1,
    :master_bind_address => '0.0.0.0',
    :master_bind_port => "37#{counter}00",
    :worker_listeners => true,
    :worker_bind_address => '127.0.0.1',
    :worker_bind_base_port => "37#{counter}01",
    :debug => false,
    :binary_path => "#{node[:ruby][:bin_path]} #{node[:languages][:ruby][:bin_dir]}/unicorn_rails",
    :env => 'production',
    :app_root => app_root,
    :enable => true,
    :config_path => "#{app_root}/current/config/unicorn.conf.rb",
    :use_bundler => false,

    :user => 2001, #app
    :gid => 2300,  #sysadmin
    :cpu_limit => 10,
    :memory_limit => 30
  })
  
  config = defaults.merge(Mash.new(node[:applications][name]))

  unicorn_instance "unicorn-#{name}" do
    options config
  end
  
  runit_service "unicorn-#{name}" do
    template_name "unicorn"
    cookbook "unicorn"
    options config
  end
    
  service "unicorn-#{name}" do
    action config[:enable] ? [:enable, :start] : [:disable, :stop]
  end

  counter += 1
end
