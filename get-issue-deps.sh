#!/usr/bin/env bash

set -uo pipefail
shopt -s expand_aliases

ISSUE_ID="$1"
JDK_VER="${2:-}"

BASE_API='https://bugs.openjdk.org/rest/api/2'
GH_BASE_API="https://api.github.com/repos/openjdk/jdk${JDK_VER}"

alias curl_gh='curl -sSL -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_PAT}" -H "X-GitHub-Api-Version: 2022-11-28"'

# CURL_ARGS='-sSL -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_PAT}" -H "X-GitHub-Api-Version: 2022-11-28"'

# curl -SsL "${BASE_API}/issue/JDK-${ISSUE_ID}" > /tmp/jdk-${ISSUE_ID}.json

dep_pr_message() {
    dep_message="$(curl_gh "${GH_BASE_API}/pulls/${1}" | jq -r '.title' | cut -d':' -f1)"
            
    echo "Issue JDK-${dep_message} might be a dependency for this issue or implement related changes
For details take a look at:
    https://bugs.openjdk.org/browse/JDK-${dep_message}
    https://github.com/openjdk/jdk/pull/${1}"
    exit 0
}

# Пробуем найти PR для 17u-dev. TODO: стоит учитывать, что их может быть несколько 
curl -SsL "${BASE_API}/issue/JDK-${ISSUE_ID}/remotelink" > /tmp/jdk-${ISSUE_ID}-links.json
JDK_U_PR=$(jq -r ".[].object.url | select(test(\"^https://.*/jdk${JDK_VER}/pull/[0-9]+\"))" "/tmp/jdk-${ISSUE_ID}-links.json" | grep -o '[^/]*$')

if [[ -z ${JDK_U_PR} ]]; then
    exit 1
fi

for pr in $JDK_U_PR; do
    curl_gh "${GH_BASE_API}/pulls/${pr}" > "/tmp/pull-${pr}.json" \
        || echo "Github API might be unavailable or there is no GH_PAT env var"

    pr_base="$(jq -r '.base.ref' "/tmp/pull-${pr}.json")"
    if [[ "${pr_base}" == 'master' ]]; then
        curl_gh "${GH_BASE_API}/issues/${pr}/comments" > "/tmp/pull-${pr}-comments.json"
        
        dependency="$(jq -r '.[].body | select(test(".*this PR into `pr/[0-9]+` will.*"))' /tmp/pull-${pr}-comments.json | grep -oE '[0-9]+')"
        if [[ -n ${dependency} ]]; then
            dep_pr_message "${dependency}"
        else
            # TODO: показывать полезные линки здесь (issue, PR, etc)
            # echo "Sorry, I could not find any dependencies for this issue, you should search manually"
            exit 1
        fi
    else
        dep_pr_message "${pr_base}"
    fi
done
