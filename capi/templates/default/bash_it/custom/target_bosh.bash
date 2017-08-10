#!/usr/bin/env bash

target_bosh() {
  green='\033[32m'
  red='\033[31m'
  nc='\033[0m'

  pool_dir=~/workspace/capi-env-pool/bosh-lites/claimed

  pushd ${pool_dir} >/dev/null
    git pull
  popd >/dev/null

  if [ -z "$1" ]; then
    echo -e "${red}Usage: target_bosh <environment>. Valid environments are:${nc}"
    ls ${pool_dir}
  else
    env_file=${pool_dir}/${1}

    if [ -f "$env_file" ]; then
      source "$env_file"
      echo -e "${green}Success!${nc}"
      env_ssh_key_path="$HOME/workspace/capi-env-pool/${1}/bosh.pem"

      if [ ! -f "$env_ssh_key_path" ]; then
        echo "$BOSH_GW_PRIVATE_KEY_CONTENTS" > "$env_ssh_key_path"
        chmod 0600 "$env_ssh_key_path"
      fi

      export BOSH_GW_PRIVATE_KEY="$env_ssh_key_path"
    else
      echo -e "${red}Environment '${1}' does not exist. Valid environments are:${nc}"
      ls ${pool_dir}
    fi
  fi
}

export -f target_bosh
