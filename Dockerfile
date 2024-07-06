# syntax=docker/dockerfile:1.4

FROM python:3.12.4-alpine AS builder
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
ENV CC='ccache gcc'

RUN \
    apk add --update --no-cache gcc ccache musl-dev libffi-dev &&\
    pip install --upgrade pip &&\
    pip install --no-cache-dir build
COPY pyproject.toml /src/
COPY get_oracle_a1_custom /src/get_oracle_a1_custom
RUN python3 -m build --wheel -o /tmp/dist /src
RUN \
  --mount=type=cache,target=/root/.cache/pip \
  --mount=type=cache,target=/root/.cache/ccache \
    pip wheel /tmp/dist/*.whl --wheel-dir /wheel

FROM python:3.12.4-alpine

MAINTAINER "sunwoo2539 <contact@sunwoo.top>"

RUN \
  --mount=type=bind,target=/wheel,from=builder,source=/wheel \
  --mount=type=bind,target=/tmp/wheel,from=builder,source=/tmp/dist \
    pip install \
      --no-cache-dir \
      --no-index \
      --find-links=/wheel \
      /tmp/wheel/*.whl

ENTRYPOINT ["/usr/local/bin/get_oracle_a1_custom"]
