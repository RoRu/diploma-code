#!/usr/bin/env python3
import common
from sys import argv

jdk17_repo = common.init_repo()

pr = jdk17_repo.get_issue(int(argv[1]))

for c in pr.get_comments():
    if c.user.login == "openjdk[bot]" and c.body.startswith("<!-- Jmerge command"):
        pushed_as_sha = c.body.splitlines()[1].split()[-1][:-1]
        pushed_as_message = jdk17_repo.get_commit(sha=pushed_as_sha).commit.message
        for s in pushed_as_message.splitlines():
            if s.startswith("Backport-of"):
                print(s.split()[-1])
        break
