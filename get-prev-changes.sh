#!/usr/bin/env bash

set -xuo pipefail
shopt -s expand_aliases

JDK_COMMIT="$1"
# FILE="$2"
JDK_PATH='${2:-../jdk}'

files=$(git diff --name-only --diff-filter=U --relative)
for file in ${files}; do
    diff_lines="$(git diff --unified=0 --no-prefix ${file} | grep -oE '[0-9]+,[0-9]+\s@@@' | cut -d',' -f1)"
    cd "${JDK_PATH}"
    parent_commit="$(git rev-parse "${JDK_COMMIT}^")"
    git checkout "${parent_commit}"

    # prev_change_commit=""
    for line in $diff_lines; do
        dep_commit="$(git blame -s -L "${line},${line}" "${file}" | cut -d' ' -f1 || true)"
        dep_issue="$(git log -1 --pretty=format:%s "${dep_commit}" | cut -d':' -f1)"
        cd -
        if [[ -z "$(git log --oneline --graph --decorate --grep "^${dep_issue}" '686d76f7721..HEAD')" ]]; then
            echo "Issue JDK-${dep_issue} might be a dependency"
        fi
        cd -
    done
    cd -
done
