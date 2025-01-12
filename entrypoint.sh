#!/bin/bash

REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

echo "REPO ${REPOSITORY}"

function get_reg_token() {
	curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" \
		https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output
}

cd /home/runner/actions-runner

REG_TOKEN=$(get_reg_token)
./config.sh --unattended --url "https://github.com/${REPOSITORY}" --token "${REG_TOKEN}"

cleanup() {
	echo "Removing runner..."
	REG_TOKEN=$(get_reg_token)
	./config.sh remove --token "${REG_TOKEN}"
}

trap "cleanup" HUP INT QUIT TERM

./run.sh & wait $!
