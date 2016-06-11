# bin/bash

function bosh-ssh() {
    if [[ "$@" == "" ]]; then
        echo "Pass the name of the environment and vm you wish to ssh into"
        echo -en "\n"
        echo "bosh-ssh <environment> [<vm>] [<deployment manifest>]"
        return 0
    fi

    ENV="$1"
    local vm="$2"
    local manifest=${3:-"/tmp/${ENV}.yml"}

    if [[ "$3" == "" ]]; then
        create_manifest
    fi

    bosh target "$ENV"
    bosh deployment "$manifest"
    bosh ssh "${vm}" --gateway_user vcap \
        --gateway_host "bosh.${ENV}.cf-app.com" \
        --gateway_identity_file "\~/workspace/capi-ci-private/${ENV}/keypair/bosh.pem"
}

function create_manifest() {
    bosh download manifest "cf-${ENV}" "/tmp/${ENV}.yml"
}

export -f bosh-ssh

