homebrew_package 'bosh-cli' do
  homebrew_user node['sprout']['user']
  action :upgrade
  options '--without-bosh2'
end
