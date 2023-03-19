# Additional automation scripts for OpenJDK Updates project

This repository contains several useful bash scripts to make backporting for OpenJDK project easier

To run those you'd need:

    * bash
    * curl
    * jq
    * git
    * Github PAT

## Description

All scripts utilise and rely on established OpenJDK Project's development processes, naming conventions and services' APIs and should not be considered general-use tools.

`backport.sh <JDK_ISSUE_ID>` - tries to find and backport issue JDK-<JDK_ISSUE_ID> to the current git repo. Uses other scripts below to find issues that the given one depends on.

`check-copyright.sh <JDK_MAIN_COMMIT>` - if a merge conflict arises while running `backport.sh`, this script checks that the only changes left unmerged are Copyright notices in files and does `git cherry-pick -X theirs` if that's the case

`get-prev-changes.sh <JDK_MAIN_COMMIT> <JDK_REPO_PATH>` - in case of a merge conflict, check JDK which JDK main repo commits changed conflicted lines and suggest those commits/issues as dependencies

`get-issue-deps.sh <JDK_ISSUE_ID>` - checks if Pull Request for a given issue has a dependency which need to go in first
