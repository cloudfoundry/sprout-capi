include_recipe 'sprout-chruby'

def chruby_gem(gem)
  rubies = node['sprout']['chruby']['rubies']
  rubies.each do |ruby_vm, ruby_versions|
    ruby_versions.each do |ruby_version|
      ruby = "#{ruby_vm}-#{ruby_version}"
      gem_for_ruby(gem, ruby)
    end
  end
end

def gem_for_ruby(gem, ruby)
  execute "install #{gem} for #{ruby}" do
    command "bash -l -c 'chruby-exec #{ruby} -- gem install #{gem}'"
    user node['sprout']['user'] unless ruby == 'system'
    environment 'GEM_PATH' => ''
  end
end

chruby_gem('bundler')
chruby_gem('bosh_cli')

# rename old BOSH CLI to bosh1
rubies = node['sprout']['chruby']['rubies']
rubies.each do |_, ruby_versions|
  ruby_versions.each do |ruby_version|
    execute "renaming ruby bosh CLI to bosh1 for ruby #{ruby_version}" do
      old_bosh_path = "#{node['sprout']['home']}/.gem/ruby/#{ruby_version}/bin/bosh"
      command "mv #{old_bosh_path} #{old_bosh_path}1"
      user node['sprout']['user']
      only_if "test -f #{old_bosh_path}"
    end
  end
end

homebrew_package 'bosh-cli' do
  homebrew_user node['sprout']['user']
  action :upgrade
  options '--without-bosh2'
end
