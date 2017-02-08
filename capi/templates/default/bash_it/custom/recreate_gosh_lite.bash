
function recreate_gosh_lite() {
  (
    set -e
    sudo true

    green='\033[32m'
    yellow='\033[33m'
    nc='\033[0m'

    update=false
    if [[ $1 == "-u" ]]; then
      echo -e "\n${green}Will Update cf-release and diego-release${nc}"
      update=true
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

      echo -e "\n${yellow}Deploying new Bosh-Lite...${nc}"
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

      # TODO: run cf-release/scripts/update if $update
      # TODO: deploy cf

      # TODO: run diego-release/scripts/update if $update
      # TODO: upload garden-runc, etcd, cflinuxfs2-rootfs releases
      # TODO: deploy diego
    popd > /dev/null
  )
}
export -f recreate_gosh_lite
