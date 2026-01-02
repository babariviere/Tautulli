FROM python:3.11-slim AS builder

LABEL maintainer="Tautulli"

COPY requirements.txt requirements.txt

RUN \
  apt-get update -q -y --no-install-recommends && \
  apt-get install -q -y --no-install-recommends \
    curl \
    gosu git && \
  pip install --no-cache-dir --upgrade pip && \
  pip install --no-cache-dir --upgrade \
    --extra-index-url https://www.piwheels.org/simple \
    -r requirements.txt && \
  rm requirements.txt && \
  rm -rf /var/lib/apt/lists/*

FROM builder

LABEL maintainer="Tautulli"

ARG BRANCH
ARG COMMIT

ENV TAUTULLI_DOCKER=True
ENV TZ=UTC

WORKDIR /app
COPY . /app
RUN \
  groupadd -g 1000 tautulli && \
  useradd -u 1000 -g 1000 tautulli && \
  echo ${BRANCH} > /app/branch.txt && \
  echo ${COMMIT} > /app/version.txt

RUN \
  mkdir /config && \
  touch /config/DOCKER
VOLUME /config

CMD [ "python", "Tautulli.py", "--datadir", "/config" ]
ENTRYPOINT [ "./start.sh" ]

EXPOSE 8181
HEALTHCHECK --start-period=90s CMD curl -ILfks https://localhost:8181/status > /dev/null || curl -ILfs http://localhost:8181/status > /dev/null || exit 1