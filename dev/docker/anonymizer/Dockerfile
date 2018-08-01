FROM ruby:2.1

MAINTAINER Mateusz Koszutowski <mkoszutowski@divante.pl>

WORKDIR /usr/src/anonymizer

ARG UID=1000
ARG GID=1000

USER root

RUN apt-get update \
    && apt-get install -y \
        mysql-client \
        rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create anonymizer user
RUN groupadd -f -g ${GID} anonymizer \
    && id -u anonymizer &> /dev/null || useradd --shell /bin/bash -u ${UID} -g ${GID} -m anonymizer

USER anonymizer
