link '/Users/pivotal/go/src/github.com/cloudfoundry/cf-acceptance-tests' do
  to '/Users/pivotal/workspace/cf-release/src/github.com/cloudfoundry/cf-acceptance-tests'
  only_if 'test -d /Users/pivotal/go && test -d /Users/pivotal/workspace/cf-release/src/github.com/cloudfoundry/cf-acceptance-tests'
end