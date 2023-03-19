#!/usr/bin/env bash

set -uo pipefail

JDK_COMMIT="$1"

files=$(git diff --name-only --diff-filter=U --relative)
for file in ${files}; do
    diff="$(git diff --unified=0 --no-prefix ${file} | grep -E "^(\+\s|-)" | grep -v "${file}")"
    if [[ "${diff}" =~ .*'Copyright'.*[0-9]+.*\.$ ]]; then 
        echo "Ok"
        git restore --staged "${file}"
        git restore "${file}"
    else
        echo "There is some non-copyright conflict in file ${file}, please wait, trying to find possible dependencies..."
        echo
        exit 1
    fi
done

if [[ -z $(git diff) ]]; then
    git cherry-pick -X theirs --no-commit "${JDK_COMMIT}" || { echo "Please check git status, there may be some merge conflits" && exit 1; }
    git stash pop || true
fi

# TODO: поменять в файлах копирайт на текущий год?
# sed -i "s|Copyright (c) 2001, 20\d\d|Copyright (c) 2001, $(date '+%Y')|" "${file}"
