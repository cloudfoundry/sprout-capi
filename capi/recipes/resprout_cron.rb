cron 'resprout-cron' do
  time :daily
  mailto nil
  command "(cd '#{node['sprout']['home']}/workspace/sprout-capi' && sudo -u #{node['sprout']['user']} git pull && bash -l -c 'cd '#{node['sprout']['home']}/workspace/sprout-capi' && HOME='#{node['sprout']['home']}' SUDO_USER='#{node['sprout']['user']}' launchctl asuser $(id -u #{node['sprout']['user']}) soloist') &> /tmp/sprout.log"
end
