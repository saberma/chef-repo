require_recipe "resque"

search(:apps, 'need_resque:true') do |app|
  conf = node[:resque][:worker]
  bluepill_monitor "bluepill_resque_#{app['id']}" do
    cookbook "resque"
    source "bluepill_workers.conf.erb"
    worker_count conf[:count]
    env_vars conf[:env_vars]
    log_path conf[:log_path] || "/tmp/bluepill_resque_#{app['id']}_stdout.log"
    working_dir "#{app[:deploy_to]}/current"
    interval 1
    user "app"
    group "app"
    memory_limit 250 # megabytes
    cpu_limit 50 # percent
    queues conf[:queues]
  end
end
