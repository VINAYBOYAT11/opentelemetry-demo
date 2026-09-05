FROM python:3.14-slim AS build
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /usr/src/app
COPY ./src/chatbot/requirements.txt .
COPY ./src/shared/tools.py ./src/shared/tools.py
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN cd src/chatbot
ENTRYPOINT ["python", "src/chatbot/run.py"]


EXPOSE ${CHATBOT_PORT}
EXPOSE 7860

