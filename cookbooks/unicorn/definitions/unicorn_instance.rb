define :unicorn_instance, :enable => true do
  require_recipe "bluepill"

  template params[:config_path] do
    owner 'app'
    group 'app'
    mode '644'
    source "unicorn.conf.erb"
    cookbook "unicorn"
    variables params
  end

  parent_params = params.except(:name)
  
  bluepill_service "bluepill_service_#{parent_params[:app]}" do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
    unicorn_log_path "#{parent_params[:app_root]}/shared/log/unicorn.log"
    #fixed: paras has set to a new hash, not the parent params
    #params.each { |k, v| send(k.to_sym, v) }
    parent_params.each { |k, v| send(k.to_sym, v) }
  end

end
