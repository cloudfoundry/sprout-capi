replay_plugin_config_path = "#{node['sprout']['home']}/.cf/plugins/CmdSetRecords"

[
  ::File.join(node['sprout']['home'], '.cf'),
  ::File.join(node['sprout']['home'], '.cf', 'plugins')
].each do |directory|
  directory directory do
    owner node['sprout']['user']
    recursive true
  end
end

cookbook_file replay_plugin_config_path do
  source "cf_cli/CmdSetRecords"
  user node['sprout']['user']
  mode "0644"
end

execute 'install cf plugin repo' do
  command 'cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org'
  user node['sprout']['user']
  not_if 'cf list-plugin-repos | grep -q CF-Community'
end

execute 'install cf cli Diego-Enabler plugin' do
  command "cf uninstall-plugin Diego-Enabler; cf install-plugin Diego-Enabler -r CF-Community -f"
  user node['sprout']['user']
end

execute 'install cf cli CLI-Recorder plugin' do
  command "cf uninstall-plugin CLI-Recorder; cf install-plugin CLI-Recorder -r CF-Community -f"
  user node['sprout']['user']
end

execute 'install cf cli open plugin' do
  command "cf uninstall-plugin open; cf install-plugin Open -r CF-Community -f"
  user node['sprout']['user']
end
