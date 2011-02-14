require_recipe "bluepill"

gem_package "resque" do
  version node[:resque][:version]
end
