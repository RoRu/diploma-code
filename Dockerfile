FROM python:3.9

COPY requirements-lock.txt ./requirements.txt
RUN pip install -r requirements.txt

RUN    apt update \
    && apt install -y \
        git \
        curl \
        jq \
        htop \
    && pip install git-deps thefuzz[speedup]
