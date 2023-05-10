#!/usr/bin/env python3

from subprocess import run
from sys import argv


def id_parent(commits: [str]):
    return str(run(
        ["git", "merge-base", "--octopus"] + commits,
        cwd="../jdk",
        # stdout=DEVNULL,
        capture_output=True,
        text=True,
        check=True
    ).stdout)


if __name__ == "__main__":
    comms = argv[1:].copy()
    while comms:
        par = id_parent(comms)[:11]
        print(par)
        comms.remove(par)
