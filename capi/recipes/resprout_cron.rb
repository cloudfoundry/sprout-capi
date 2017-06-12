cron 'resprout-cron' do
  time :daily
  mailto nil
  environment "PATH" => "/usr/local/bin:/usr/bin:/bin"
  command "(launchctl asuser $(id -u #{node['sprout']['user']}) sudo -i -u #{node['sprout']['user']} 'cd '#{node['sprout']['home']}/workspace/sprout-capi' && git pull && soloist') &> /tmp/sprout.log"
end
