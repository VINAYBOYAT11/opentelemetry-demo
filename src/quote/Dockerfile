# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM ghcr.io/mlocati/php-extension-installer:2.11.12 AS installer
FROM docker.io/library/composer:2.10.2 AS vendor
WORKDIR /tmp

# Download the PHP packages before building the service image.
COPY ./src/quote/composer.json composer.json
RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist

FROM docker.io/library/php:8.5.9-cli-alpine3.24
COPY --from=installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions opcache pcntl protobuf opentelemetry
WORKDIR /var/www
USER www-data

# Run the application with the non-root web user.
COPY --from=vendor /tmp/vendor ./vendor
COPY ./src/quote/app/ app/
COPY ./src/quote/public/ public/
COPY ./src/quote/src/ src/

EXPOSE ${QUOTE_PORT}

CMD ["php", "public/index.php"]
