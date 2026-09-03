# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/library/python:3.14.7-slim-bookworm AS builder
WORKDIR /app

COPY requirements.txt ./requirements.txt

RUN python -m venv /opt/venv \
	&& /opt/venv/bin/pip install --no-cache-dir --require-hashes -r requirements.txt

FROM docker.io/library/python:3.14.7-slim-bookworm
WORKDIR /app
ENV PATH="/opt/venv/bin:$PATH"

COPY --from=builder /opt/venv /opt/venv
COPY *.py ./

ENTRYPOINT ["python", "recommendation_server.py"]