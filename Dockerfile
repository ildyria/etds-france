FROM httpd:2.4 AS base

# Set version label
LABEL maintainer="Benoit Viguier"

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='biv'
ENV PHP_TZ=UTC

# Multi-stage build: Build static assets
# This allows us to not include Node within the final container
FROM node:20 AS node_builder

RUN mkdir -p  /app/dist

WORKDIR /app

COPY src /app/src
COPY public /app/public
COPY vendor /app/vendor
COPY .npmrc /app/package.json
COPY astro.config.mjs /app/astro.config.mjs
COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
COPY tailwind.config.cjs /app/tailwind.config.cjs
COPY tsconfig.json /app/tsconfig.json

RUN \
    npm ci --no-audit && \
    npm run build

FROM base
COPY --from=node_builder --chown=www-data:www-data /app/dist/ /usr/local/apache2/htdocs/
