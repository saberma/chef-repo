define :unicorn_instance, :enable => true do

  template params[:conf_path] do
    source "unicorn.conf.erb"
    cookbook "unicorn"
    variables params
  end

  bluepill_monitor app do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
    unicorn_log_path "#{params[:app_root]}/shared/log/unicorn.log"
    params.each { |k, v| send(k.to_sym, v) }
  end

end
