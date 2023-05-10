from github import Github
from envparse import env
from requests_cache import SQLiteCache, install_cache


def init_repo(repo="openjdk/jdk17u-dev"):
    install_cache(
        backend=SQLiteCache("http_cache", timeout=10),
        expire_after=7200,
        allowable_methods="GET",
    )

    g = Github(env.str("GH_PAT"))
    return g.get_repo(repo)
