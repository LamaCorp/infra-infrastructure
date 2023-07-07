FROM python:3.10 as base

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_VIRTUALENVS_CREATE=false \
  PATH="/opt/venv/bin:/root/.cargo/bin:$PATH"

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl ca-certificates gnupg apt-transport-https git software-properties-common

# Golang
RUN apt-get install -y --no-install-recommends golang-go

# Shellcheck
RUN apt-get install -y --no-install-recommends shellcheck

# Terraform
RUN curl -1sLf https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends terraform

RUN apt-get update && \
  apt-get install -y --no-install-recommends gcc python3-dev git

RUN --mount=type=bind,target=./pyproject.toml,src=./pyproject.toml \
  --mount=type=bind,target=./poetry.lock,src=./poetry.lock \
  --mount=type=cache,target=/root/.cache/pip \
  python -m venv /opt/venv && \
  pip3 install --upgrade pip && \
  pip3 install --upgrade poetry && \
  poetry install
