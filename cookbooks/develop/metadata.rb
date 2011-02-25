maintainer       "ShopQi, Inc."
maintainer_email "mahb45@gmail.com"
license          "Apache 2.0"
description      "build shopqi develop box"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
recipe "users::sysadmin", "searches users data bag for sysadmins and creates users"
version          "0.0.1"
