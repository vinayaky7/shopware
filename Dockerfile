#syntax=docker/dockerfile:1.9

# build assets in build stage
FROM ghcr.io/friendsofshopware/shopware-cli:latest-php-8.2 as build

ADD . /src
WORKDIR /src

RUN --mount=type=secret,id=composer_auth,dst=/src/auth.json \
    --mount=type=cache,target=/root/.composer \
    --mount=type=cache,target=/root/.npm \
    K8S_CACHE_TYPE="cache.adapter.array" /usr/local/bin/entrypoint.sh shopware-cli project ci /src


FROM shopware/docker-base:8.2-caddy

COPY --chown=82:82 setup.sh /setup.sh
RUN chmod 777 /setup.sh

# copy assets from build stage
COPY --from=build --chown=82 --link /src /var/www/html

