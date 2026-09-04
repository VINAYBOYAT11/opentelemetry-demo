FROM python:3.14-slim AS build
WORKDIR /app
COPY ./src/agent/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
COPY ./src/agent/run.py ./run.py
COPY ./ ./
COPY ./src/shared/tools.py ./src/agent/src/agents/tools.py

ENV PYTHONPATH=/app/src/agent
ENTRYPOINT ["python", "./run.py"]

ENV AGENT_PORT=8010

EXPOSE ${AGENT_PORT}