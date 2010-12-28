#
# Cookbook Name:: openvpn
# Attributes:: openvpn
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#default[:openvpn][:local]   = ipaddress
default[:openvpn][:local]   = '184.82.227.170'
default[:openvpn][:proto]   = "tcp"
default[:openvpn][:type]    = "server"
default[:openvpn][:subnet]  = "10.8.0.0"
default[:openvpn][:netmask] = "255.255.0.0"
