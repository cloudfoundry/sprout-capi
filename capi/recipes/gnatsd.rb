execute 'go get github.com/nats-io/gnatsd' do
    user node['sprout']['user']
    environment('GOPATH' => File.join(node['sprout']['home'], 'go'))
end

