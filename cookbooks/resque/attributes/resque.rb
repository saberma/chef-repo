default.resque[:version] = "1.10.0"
default.resque[:worker] = {
  :count => 1,
  :env_vars => "production",
  :working_dir => "production",
  :queues => ["*"]
}
