function claim_bosh_lite() {
  env_file=$(
    set -e

    function msg {
      echo -e $1
    }

    function realpath {
      echo $(cd $(dirname "$1") && pwd -P)/$(basename "$1")
    }

    function claim_random_environment() {
      pool="bosh-lites"

      git pull --rebase --quiet

      for f in ./${pool}/unclaimed/*; do
        test -f "$f" || continue

        msg "Claiming $( basename $f )..."
        claim_specific_environment $(basename $f)
        return $?
      done

      msg "No unclaimed environment found in $pool"
      return 1
    }

    function claim_specific_environment() {
      env=$1

      file=`find . -name $env`

      if [ "$file" == "" ]; then
        echo $env does not exist
        return 1
      fi

      set +e
      file_unclaimed=`echo $file | grep claim | grep -v unclaim`
      set -e

      if [ $file_unclaimed ]; then
        msg $env could not be claimed
        return 1
      fi

      newfile=`echo ${file} | sed -e 's/unclaimed/claimed/'`

      git mv $file $newfile
      git ci --quiet --message "manually claim ${env} on ${HOSTNAME} [nostory]" --no-verify
      msg "Pushing reservation to $( basename $PWD )..."
      git push --quiet
      msg "Done\n"
    }

    >&2 cd ~/workspace/capi-env-pool
    >&2 claim_random_environment $requested_input

    realpath $newfile
  )

  if [ "$?" == 0 ]; then
    source "${env_file}"

    env_name="$( basename "${env_file}" )"
    env_ssh_key_path="$HOME/workspace/capi-env-pool/keypairs/${env_name}.pem"
    echo "$BOSH_GW_PRIVATE_KEY_CONTENTS" > "${env_ssh_key_path}"
    chmod 0400 "${env_ssh_key_path}"
    export BOSH_GW_PRIVATE_KEY="${env_ssh_key_path}"

    echo -e "Now targeting Director at \`${BOSH_ENVIRONMENT}\`"
    echo -e "Your CF system_domain is \`${BOSH_LITE_DOMAIN}\`"
    echo -e "To target that environment in other sessions, run \`source ${env_file}\`"
    echo -e "To unclaim the environment, run \`unclaim_bosh_lite ${env_name}\`"
  fi
}

export -f claim_bosh_lite
