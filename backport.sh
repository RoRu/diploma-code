#!/usr/bin/env bash

set -xuo pipefail

ISSUE_ID="$1"
# JDK_VER="$2"

BASE_API="https://bugs.openjdk.org/rest/api/2"



# здесь найти коммит из jdk и применить его на u-dev
if [[ ! -f "/tmp/jdk-${ISSUE_ID}-links.json" ]]; then
    curl -SsL "${BASE_API}/issue/JDK-${ISSUE_ID}/remotelink" > /tmp/jdk-${ISSUE_ID}-links.json
fi
JDK_COMMIT=$(jq -r '.[].object.url | select(test("^https://.*/jdk/commit/[0-9a-zA-Z]*"))' "/tmp/jdk-${ISSUE_ID}-links.json" | grep -o '[^/]*$')

# TODO: just in case check that we found the right commit

if [[ -z ${JDK_COMMIT} ]]; then
    echo "Sorry, most likely there is no commit for this issue yet. Please check at https://bugs.openjdk.org/browse/JDK-${ISSUE_ID}"
    exit 1
fi

git stash
git fetch --no-tags https://github.com/openjdk/jdk "${JDK_COMMIT}"
git cherry-pick --no-commit "${JDK_COMMIT}" \
    && { git add --update && git stash pop || true; } \
    || { ./check-copyright.sh "${JDK_COMMIT}" || exit 1; }

git status
if [[ ! -f "/tmp/jdk-${ISSUE_ID}.json" ]]; then
    curl -SsL "${BASE_API}/issue/JDK-${ISSUE_ID}" > /tmp/jdk-${ISSUE_ID}.json
fi
read -p "Commit changes?  " choice
echo
if [[ $choice =~ ^[Yy]$ ]]; then
    # TODO: изменить сообщения на Backport $JDK_COMMIT
    git commit -m "${ISSUE_ID}: $(jq -r '.fields.summary' /tmp/jdk-${ISSUE_ID}.json)"
else
    echo "You can commit this change by executing:
        git commit -m '${ISSUE_ID}: $(jq -r '.fields.summary' /tmp/jdk-${ISSUE_ID}.json)'"
fi
