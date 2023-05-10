#!/usr/bin/env python3

from jira import JIRA


def find_commit(links, repo="jdk"):
    for li in links:
        spl = li.split("/")
        if spl[3] == f"{repo}" and spl[4] == "commit":
            return spl[-1]
    return ""


def find_pr(links, repo="jdk17u-dev"):
    pr = 0
    for li in links:
        spl = li.split("/")
        if spl[3] == f"{repo}" and spl[4] == "pull":
            pr_num = int(spl[-1])
            pr = pr_num if pr_num > pr else pr
    return pr


jira = JIRA("https://bugs.openjdk.org")

links = jira.remote_links("JDK-8269404")
# for i in links:
#     print(i.object.url)

print(find_commit([i.object.url for i in links]))
print(find_pr([i.object.url for i in links]))
