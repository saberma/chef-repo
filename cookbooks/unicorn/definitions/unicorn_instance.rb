define :unicorn_instance, :enable => true do

  template params[:config_path] do
    owner 'app'
    group 'app'
    mode '644'
    source "unicorn.conf.erb"
    cookbook "unicorn"
    variables params
  end

  bluepill_service "bluepill_service_#{params[:app]}" do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
    unicorn_log_path "#{params[:app_root]}/shared/log/unicorn.log"
    params.each { |k, v| send(k.to_sym, v) }
  end

end
