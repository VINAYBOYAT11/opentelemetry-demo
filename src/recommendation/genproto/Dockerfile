# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/library/python:3.14.7-slim-bookworm

WORKDIR /build
COPY ./src/recommendation/genproto/requirements.txt requirements.txt
RUN python -m pip install --no-cache-dir --require-hashes -r requirements.txt