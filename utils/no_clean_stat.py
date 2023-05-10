#!/usr/bin/env python3

import common
from datetime import datetime as dt

repo = common.init_repo()

non_clean_prs = []

for i in repo.get_issues(
    state="closed",
    labels=["backport", "integrated"],
    since=dt.fromtimestamp(1672534800),  # Jan 1st 2023
):
    if "clean" not in [n.name for n in i.labels]:
        non_clean_prs.append(i)

print(len(non_clean_prs))
