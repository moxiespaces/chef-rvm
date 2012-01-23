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

install_rubies  = node['rvm']['install_rubies'] == true ||
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

if install_rubies
  # install additional rubies
  node['rvm']['rubies'].each do |rubie|
    rvm_ruby rubie do
     options ruby_options
    end
  end

  # set a default ruby
  rvm_default_ruby node['rvm']['default_ruby']
  
  # install global gems
  node['rvm']['global_gems'].each do |gem|
    rvm_global_gem gem[:name] do
      version   gem[:version] if gem[:version]
      action    gem[:action]  if gem[:action]
      options   gem[:options] if gem[:options]
      source    gem[:source]  if gem[:source]
    end
  end

  # install additional gems
  node['rvm']['gems'].each_pair do |rstring, gems|
    rvm_environment rstring

    gems.each do |gem|
      rvm_gem gem[:name] do
        ruby_string   rstring
        version       gem[:version] if gem[:version]
        action        gem[:action]  if gem[:action]
        options       gem[:options] if gem[:options]
        source        gem[:source]  if gem[:source]
      end
    end
  end
end

# add users to rvm group
if node['rvm']['group_users'].any?
  group 'rvm' do
    members node['rvm']['group_users']
  end
end
