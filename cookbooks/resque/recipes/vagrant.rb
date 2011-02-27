require_recipe "resque"

runit_service "resque-vagrant" do
  template_name "vagrant"
  cookbook "resque"
end
