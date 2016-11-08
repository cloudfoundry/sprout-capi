remote_file "#{Chef::Config[:file_cache_path]}/cred-alert-cli" do
  source node['sprout']['cred_alert']['download_url']
  owner node['sprout']['user']
end

execute 'install cred alert cli' do
  command "install #{Chef::Config[:file_cache_path]}/cred-alert-cli /usr/local/bin/cred-alert-cli"
  user node['sprout']['user']
end

execute 'remove the binary' do
  command "rm #{Chef::Config[:file_cache_path]}/cred-alert-cli"
  user node['sprout']['user']
end
