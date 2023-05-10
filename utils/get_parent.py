#!/usr/bin/env python3
import common

repo = common.init_repo()

pr = repo.get_issue(936)

for c in pr.get_comments():
    if c.user.login == "openjdk[bot]" and c.body.startswith("<!-- prepush"):
        # find the first commit that was applied to master before merge
        first_commit = c.body.splitlines()[-5:-4][0].split()[1][:-1]
        true_parent = repo.get_commit(sha=first_commit).parents[0].sha
        print(true_parent)
