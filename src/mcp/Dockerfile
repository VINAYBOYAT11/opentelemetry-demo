# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
# Install tools needed by Python packages during installation.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY src/mcp/requirements.txt .
# Install the MCP service dependencies.
RUN pip install --no-cache-dir --require-hashes -r requirements.txt

COPY src/mcp/src src
COPY src/shared/tools.py src/mcp_server
COPY src/mcp/run.py .

EXPOSE ${MCP_PORT}

CMD ["python", "run.py"]
