default[:coreseek][:install_path] = "/opt/coreseek"
default[:coreseek][:mmseg_install_path] = "#{default[:coreseek][:install_path]}/mmseg3"
default[:coreseek][:version]      = '3.2.14' #基于sphinx0.9.9
default[:coreseek][:url]          = "http://www.coreseek.cn/uploads/csft/3.2/coreseek-#{coreseek[:version]}.tar.gz"

default[:coreseek][:use_mysql]    = false
default[:coreseek][:use_postgres] = true

default[:coreseek][:configure_flags] = [
  "--prefix=#{coreseek[:install_path]}",
  "--without-unixodbc",
  "--with-mmseg",
  "--with-mmseg-includes=#{coreseek[:mmseg_install_path]}/include/mmseg/",
  "--with-mmseg-libs=#{coreseek[:mmseg_install_path]}/lib/",
  "#{coreseek[:use_mysql] ? '--with-mysql' : '--without-mysql'}",
  "#{coreseek[:use_postgres] ? '--with-pgsql' : '--without-pgsql'}",
]
