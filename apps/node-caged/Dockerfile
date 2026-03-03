FROM debian:13-slim AS build

ARG VERSION

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    dirmngr \
    xz-utils \
    python3 \
    g++ \
    gcc \
    make \
    --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

RUN set -ex \
  && export GNUPGHOME="$(mktemp -d)" \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && for key in \
    5BE8A3F6C8A5C01D106C0AD820B1A390B168D356 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    A363A499291CBBC940DD62E41F10027AF002F8B0 \
  ; do \
    { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || \
    { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$VERSION/node-v$VERSION.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && grep " node-v$VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$VERSION.tar.xz" \
  && rm "node-v$VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

WORKDIR /node-v$VERSION

RUN ./configure \
    --prefix=/usr/local \
    --experimental-enable-pointer-compression \
  && make -j"$(nproc)" \
  && make install

# smoke tests
RUN node --version && npm --version

FROM debian:13-slim

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# Copy the built Node.js installation from the build stage
COPY --from=build /usr/local /usr/local

RUN apt-get update \
  && apt-get install -y --no-install-recommends libatomic1 libstdc++6 \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && node --version \
  && npm --version

ARG YARN_VERSION

RUN set -ex \
  && savedAptMark="$(apt-mark showmanual)" \
  && apt-get update && apt-get install -y ca-certificates curl gnupg dirmngr --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && export GNUPGHOME="$(mktemp -d)" \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || \
    { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && apt-mark auto '.*' > /dev/null \
  && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; } \
  && find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && yarn --version \
  && rm -rf /tmp/*

ENTRYPOINT ["node"]
CMD ["--version"]
