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
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && for key in \
    5BE8A3F6C8A5C01D106C0AD820B1A390B168D356 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    655F3B5C1FB3FA8D1A0CA6BDE4A7D232B936D2FD \
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
  && apt-get install -y ca-certificates curl wget gnupg dirmngr xz-utils libatomic1 --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && node --version \
  && npm --version

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
