#!/bin/bash

recreate_gosh_lite() {
  (
    set -e
    sudo true

    green='\033[32m'
    yellow='\033[33m'
    red='\033[31m'
    nc='\033[0m'

    update=false
    if [[ "$1" == "-u" ]]; then
      update=true
    fi

		hour="$(date +%H)"
		if [ "${hour}" -lt 11 ]; then
			greeting="morning"
		elif [ "${hour}" -lt 17 ]; then
			greeting="afternoon"
		else
			greeting="evening"
		fi
    echo -e "\n${green}Good ${greeting}, let's get you a new bosh-lite!${nc}"

    cf_release_dir="$HOME/workspace/cf-release"
    diego_release_dir="$HOME/workspace/diego-release"
    old_bosh_lite_dir="$HOME/workspace/bosh-lite"

    if [ -d "${old_bosh_lite_dir}/.vagrant" ]; then
      pushd "${old_bosh_lite_dir}" > /dev/null
        set +e
        vagrant --machine-readable status | grep -q 'state,running'
        is_running="$?"
        set -e
      popd > /dev/null

      if [ "${is_running}" = "0" ]; then
        echo -e "\n${red}ERR: Looks like you have a running vagrant bosh-lite at ${old_bosh_lite_dir}. Please 'vagrant suspend' it before continuing.${nc}"
        exit 1
      fi
    fi

    deployment_repo="$HOME/workspace/bosh-deployment"
    if [ ! -d "${deployment_repo}" ]; then
      echo -e "\n${green}Fetching bosh-deployment...${nc}"
      git clone https://github.com/cloudfoundry/bosh-deployment.git \
        "${deployment_repo}"
    fi

    state_dir="$HOME/deployments/vbox"
    mkdir -p "${state_dir}"

    pushd "${state_dir}" > /dev/null
      gosh interpolate "${deployment_repo}/bosh.yml" \
        -o "${deployment_repo}/virtualbox/cpi.yml" \
        -o "${deployment_repo}/virtualbox/outbound-network.yml" \
        -o "${deployment_repo}/bosh-lite.yml" \
        -o "${deployment_repo}/bosh-lite-runc.yml" \
        -v director_name="Bosh Lite Director" \
        -v admin_password="admin" \
        -v internal_ip=192.168.50.4 \
        -v internal_gw=192.168.50.1 \
        -v internal_cidr=192.168.50.0/24 \
        -v network_name=vboxnet0 \
        -v outbound_network_name=NatNetwork \
        > ./director.yml

      if [ -f "${state_dir}/state.json" ]; then
        echo -e "\n${yellow}Destroying current Bosh-Lite...${nc}"
        gosh delete-env \
           --state=./state.json \
           --vars-store ./creds.yml \
          ./director.yml
      fi

      echo -e "\n${green}Deploying new Bosh-Lite...${nc}"
      gosh create-env \
         --state=./state.json \
         --vars-store ./creds.yml \
        ./director.yml

      echo -e "\n${green}Setting up route table entries...${nc}"
      sudo route delete -net 10.244.0.0/16 192.168.50.4
      sudo route add -net 10.244.0.0/16 192.168.50.4

      echo -e "\n${green}Uploading stemcell...${nc}"
      bosh target 192.168.50.4 lite
      bosh upload stemcell \
        https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent

      if $update; then
        echo -e "\n${green}Updating source for cf-release...${nc}"
        "${cf_release_dir}/scripts/update"
      fi

      echo -e "\n${green}Deploying cf-release...${nc}"
      "${cf_release_dir}/scripts/deploy-dev-release-to-bosh-lite"


      if $update; then
        echo -e "\n${green}Updating source for diego-release...${nc}"
        "${diego_release_dir}/scripts/update"
      fi

      echo -e "\n${green}Deploying diego-release...${nc}"
      pushd "${diego_release_dir}" > /dev/null
        bosh --parallel 10 sync blobs
        bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
        bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release
        bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release

        ./scripts/deploy
        bosh deployment "${cf_release_dir}/bosh-lite/deployments/cf.yml"
      popd > /dev/null
    popd > /dev/null

    echo -e "\n${green}Another successful deployment, have a nice day!${nc}"
  )
}
export -f recreate_gosh_lite
