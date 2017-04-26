function unclaim_bosh_lite() {
  (
    cd ~/workspace/capi-ci-private

    if [ $# -eq 0 ]; then
      echo 'Usage: $0 env_name'
      return 1
    fi

    git pull -r --quiet

    function unclaim {
      env=$1
      file=`find . -name $env`

      if [ "$file" == "" ]; then
        echo $env does not exist
        return 1
      fi

      set +e
      file_unclaimed=`echo $file | grep unclaim`
      set -e

      if [ $file_unclaimed ]; then
        echo $env is not claimed
        return 1
      fi

      read -p "Hit enter to unclaim $env "

      newfile=`echo $file | sed -e 's/claimed/unclaimed/'`
      git mv $file $newfile
      git ci --quiet -m"manually unclaim $env on ${HOSTNAME} [nostory]" --no-verify
      echo "Pushing the unclaim commit to $( basename $PWD )..."
      git push --quiet
    }

    for env in "$@"; do
      unclaim $env
    done
  )

  unset BOSH_CA_CERT BOSH_CLIENT BOSH_CLIENT_SECRET BOSH_ENVIRONMENT \
    BOSH_GW_USER BOSH_GW_HOST BOSH_LITE_DOMAIN BOSH_GW_PRIVATE_KEY_CONTENTS

  echo "Done"
}

export -f unclaim_bosh_lite
