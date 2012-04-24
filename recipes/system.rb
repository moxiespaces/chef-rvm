#
# Cookbook Name:: rvm
# Recipe:: system
#
# Copyright 2010, 2011 Fletcher Nichol
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

include_recipe "rvm::system_install"

perform_install_rubies  = node['rvm']['install_rubies'] == true ||
                  node['rvm']['install_rubies'] == "true"

ruby_patch_url=node['rvm']['ruby_patch_url']
ruby_options = Hash.new
  if ruby_patch_url
    ruby_file=node['rvm']['ruby_patch_file']
    ruby_patch_cmd=`curl -s #{ruby_patch_url} > #{ruby_file}`
  #  Chef::Log.info("#{ruby_patch_cmd}, #{ruby_file}")
    ruby_options = { :patch => ruby_file, :force => true }
   # Chef::Log.info("Patching rvm_ruby[#{rubie}] from #{rvm_patch_url}")
  end

if perform_install_rubies
  install_rubies  :rubies => node['rvm']['rubies'],
                  :default_ruby => node['rvm']['default_ruby'],
                  :global_gems => node['rvm']['global_gems'],
                  :gems => node['rvm']['gems'],
                  :options => ruby_options
end

# add users to rvm group
if node['rvm']['group_users'].any?
  group 'rvm' do
    members node['rvm']['group_users']
  end
end
