alias resprout='(cd ~/workspace/sprout-capi && git pull && chruby-exec system -- bundle exec soloist)'

# CATs
alias cats='(cd ~/workspace/cf-release/src/github.com/cloudfoundry/cf-acceptance-tests && CONFIG=$PWD/integration_config.json bin/test --nodes=3)'

# Deploying (bosh1 + cf-release)
alias qnd-deploy='(cd ~/workspace/cf-release && scripts/deploy-dev-release-to-bosh-lite --no-manifest)'
alias qnd-deploy-diego='(cd ~/workspace/diego-release && bosh --parallel 10 sync blobs && scripts/update && scripts/deploy && bosh deployment ~/workspace/cf-release/bosh-lite/deployments/cf.yml)'
alias qnd-deploy-manifest='(cd ~/workspace/cf-release && scripts/deploy-dev-release-to-bosh-lite)'

# Deploying (bosh2 + cf-deployment)
alias upload-capi-release='(cd ~/workspace/capi-release && bosh sync-blobs && bosh create-release --force --name capi && bosh upload-release --rebase)'

# PSQL
alias psql-bosh-lite='psql -h 10.244.0.30 -p 5524 -U ccadmin ccdb'

#FASD
alias v='fasd -e vim'

alias b='bundle exec'
alias bake='bundle exec rake'

# Git aliases
alias gd='git diff'
alias gdc='git diff --cached'
alias g='git status'

# Misc aliases
alias gi='gem install'
