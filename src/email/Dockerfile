FROM ruby:3.4 AS builder

WORKDIR /app

COPY ./src/email/. ./
#fix for google-protobuf gem issue on linux
RUN bundle lock --add-platform x86_64-linux
RUN bundle install

FROM ruby:3.4-slim AS runtime

WORKDIR /app

COPY --from=builder ./usr/local/bundle/ /usr/local/bundle/
COPY --from=builder ./app/ ./



CMD ["bundle", "exec", "email_server.rb"]

EXPOSE 6060