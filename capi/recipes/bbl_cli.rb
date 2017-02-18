execute 'go get github.com/cloudfoundry/bosh-bootloader/bbl' do
    user node['sprout']['user']
    environment('GOPATH' => File.join(node['sprout']['home'], 'go'))
end

