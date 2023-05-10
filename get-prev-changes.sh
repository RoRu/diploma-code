#!/usr/bin/env bash

set -uo pipefail
shopt -s expand_aliases

JDK_COMMIT="$1"
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
    # 4afbcaf55383ec2f5da53282a1547bac3d099e9d - is a merge-base for jdk and jdk17u-dev
    if [[ -z "$(git log --oneline --grep "^${dep_issue}" '4afbcaf55383ec2f5da53282a1547bac3d099e9d..HEAD')" ]]; then
        echo "${dep_commit}" >> "/tmp/jdk-deps.txt"
        echo "Issue JDK-${dep_issue} might be a dependency"
    fi
}

files=$(git diff --name-only --diff-filter=U --relative)
for file in ${files}; do
    diff_lines="$(git diff --unified=0 --no-prefix ${file} | grep -oE '@@@\s-[0-9]+' | cut -d'-' -f2)"
    if [[ -z $diff_lines && "$(git diff $file)" == *Unmerged* ]]; then
        get_dep 1
    fi

    for line in $diff_lines; do
        get_dep 2
    done
done
