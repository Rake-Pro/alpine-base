# syntax=docker/dockerfile:1

# Shared runtime base for the in-house application images (sonarr, radarr,
# jackett, qbittorrent-nox, tautulli, gluetun). Alpine with the distro security
# patches applied at build time, a static init (catatonit) and CA/timezone
# data. Nothing else: packages the applications need live in their own
# Dockerfiles. Rebuilt weekly (rebuild.yml) so :latest and the current semver
# tag always carry the newest Alpine patch set; consumers pin by digest and
# Dependabot opens the digest bump.
FROM docker.io/library/alpine:3.24

LABEL org.opencontainers.image.source="https://github.com/Rake-Pro/alpine-base" \
      org.opencontainers.image.description="Alpine runtime base: security patches applied, catatonit init, CA and tzdata"

ENV TZ="Etc/UTC"

RUN apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        catatonit \
        tzdata \
    && rm -rf /var/cache/apk/*

# Consumers run as the unprivileged uid/gid 65534 (Alpine's nobody user). The
# base stays root so downstream RUN steps can install packages; every consumer
# ends with USER 65534:65534.
