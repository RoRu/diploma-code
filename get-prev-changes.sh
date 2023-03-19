#!/usr/bin/env bash

set -uo pipefail
shopt -s expand_aliases

JDK_COMMIT="$1"
# FILE="$2"
JDK_PATH="${2:-../jdk}"

get_dep() {
    cd "${JDK_PATH}"
    parent_commit="$(git rev-parse "${JDK_COMMIT}^")"
    git checkout "${parent_commit}" >/dev/null 2>&1
    if [[ $1 == 1 ]]; then
        dep_issue="$(git log --pretty=format:%s --diff-filter=A -- $file | cut -d':' -f1)"
    else
        dep_commit="$(git blame -s -L "${line},${line}" "${file}" | cut -d' ' -f1 || true)"
        dep_issue="$(git log -1 --pretty=format:%s "${dep_commit}" | cut -d':' -f1)"
    fi
    cd - >/dev/null 2>&1
    if [[ -z "$(git log --oneline --graph --decorate --grep "^${dep_issue}" '686d76f7721..HEAD')" ]]; then
        echo "Issue JDK-${dep_issue} might be a dependency"
    fi
    cd - >/dev/null 2>&1
}

files=$(git diff --name-only --diff-filter=U --relative)
for file in ${files}; do
    diff_lines="$(git diff --unified=0 --no-prefix ${file} | grep -oE '[0-9]+,[0-9]+\s@@@' | cut -d',' -f1)"
    if [[ -z $diff_lines && "$(git diff $file)" == *Unmerged* ]]; then
        get_dep 1
    fi

    # prev_change_commit=""
    for line in $diff_lines; do
        get_dep 2
    done
    cd - >/dev/null 2>&1
done
