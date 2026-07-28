FROM sparkison/m3u-editor:0.11.69@sha256:b49c716a06f43d02dcf785624ffdb9e4b78faf5b32d791fad3559a2a8f7b2aa2 AS upstream

FROM alpine:3.23@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40 AS patcher

RUN apk add --no-cache git

WORKDIR /work

RUN mkdir -p docker/8.4/nginx

COPY --from=upstream /usr/local/bin/start-container ./start-container
COPY --from=upstream /etc/supervisor/conf.d/supervisord.conf ./docker/8.4/supervisord.conf
COPY --from=upstream /etc/nginx/nginx.tmpl ./docker/8.4/nginx/nginx.conf
COPY ./patches/rootless.patch /patches/rootless.patch

RUN set -eux; \
    git apply --check /patches/rootless.patch; \
    git apply /patches/rootless.patch

FROM upstream

USER root

COPY --from=patcher --chown=root:root --chmod=0555 /work/start-container /usr/local/lib/m3u-editor/start-container
COPY --from=patcher --chown=root:root --chmod=0444 /work/docker/8.4/nginx/nginx.conf /etc/nginx/nginx.tmpl
COPY --from=patcher --chown=root:root --chmod=0444 /work/docker/8.4/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=root:root ./rootfs/ /

RUN set -eux; \
    chmod 0555 /usr/local/bin/start-container-rootless; \
    chmod 0444 /usr/local/share/m3u-editor/php-fpm.conf; \
    mv /etc/nginx/conf.d /usr/local/share/m3u-editor/nginx-conf.d; \
    install -d -m 0755 /var/lib/nginx/logs; \
    rm -rf \
        /.composer \
        /etc/nginx/nginx.conf \
        /etc/php84/php-fpm.conf \
        /etc/php84/php-fpm.d/www.conf \
        /etc/redis/redis.conf \
        /var/lib/nginx/logs/error.log \
        /var/log/cron.err.log \
        /var/log/cron.out.log; \
    ln -s /tmp/m3u-editor/composer /.composer; \
    ln -s /tmp/m3u-editor/nginx/conf.d /etc/nginx/conf.d; \
    ln -s /tmp/m3u-editor/nginx.conf /etc/nginx/nginx.conf; \
    ln -s /usr/local/share/m3u-editor/php-fpm.conf /etc/php84/php-fpm.conf; \
    ln -s /tmp/m3u-editor/php-fpm-pool.conf /etc/php84/php-fpm.d/www.conf; \
    ln -s /tmp/m3u-editor/redis.conf /etc/redis/redis.conf; \
    ln -s /dev/stderr /var/lib/nginx/logs/error.log; \
    ln -s /dev/stderr /var/log/cron.err.log; \
    ln -s /dev/stdout /var/log/cron.out.log; \
    install -d -o m3ue -g m3ue -m 0770 /var/www/config; \
    rm -rf \
        /var/www/html/.env \
        /var/www/html/database/database.sqlite \
        /var/www/html/database/jobs.sqlite \
        /var/www/html/plugins \
        /var/www/html/public/storage \
        /var/www/html/storage/logs; \
    ln -s /var/www/config/env /var/www/html/.env; \
    ln -s /var/www/config/database/database.sqlite /var/www/html/database/database.sqlite; \
    ln -s /var/www/config/database/jobs.sqlite /var/www/html/database/jobs.sqlite; \
    ln -s /var/www/config/plugins /var/www/html/plugins; \
    ln -s /var/www/html/storage/app/public /var/www/html/public/storage; \
    ln -s /var/www/config/logs /var/www/html/storage/logs

ENV APP_PORT="36400" \
    COMPOSER_HOME="/tmp/m3u-editor/composer" \
    HLS_TEMP_DIR="/var/www/html/storage/app/hls-segments" \
    HOME="/var/www/html" \
    XDG_CACHE_HOME="/tmp/m3u-editor/cache"

VOLUME ["/var/www/config", "/var/www/html/bootstrap/cache", "/var/www/html/storage/app", "/var/www/html/storage/framework"]

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/start-container-rootless"]
