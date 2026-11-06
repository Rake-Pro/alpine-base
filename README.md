# alpine-base

Shared Alpine runtime base for the in-house application images.

```
ghcr.io/rake-pro/alpine-base
```

## What is in it

| Item | Value |
| --- | --- |
| Base | `docker.io/library/alpine:3.23` with `apk upgrade` applied at build time |
| Init | `catatonit` at `/usr/bin/catatonit` |
| Packages | `ca-certificates`, `tzdata` |
| User | root (consumers switch to `65534:65534` after installing packages) |
| Env | `TZ=Etc/UTC` |
| Platform | linux/amd64 |

## Tags

| Tag | Meaning |
| --- | --- |
| `X.Y.Z` | Immutable release, built from git tag `vX.Y.Z` |
| `X.Y` | Latest patch of that minor; re-pushed by the weekly rebuild |
| `latest` | Latest release; re-pushed by the weekly rebuild |
| `sha-<short>` | Commit the image was built from |
| `dev`, `dev-<sha>` | Every push to `dev`, for testing a base change downstream |

## Consuming it

- Pin by tag and digest so Dependabot opens a PR when the weekly rebuild moves the digest:

```
FROM ghcr.io/rake-pro/alpine-base:1.0@sha256:<digest>
```

- Install runtime packages with `apk add --no-cache`, copy the application in, then `USER 65534:65534`.
- Use `ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]`.

## Release flow

- `dev` is the integration branch; `ci.yml` builds, smoke-tests and pushes `:dev` on every push.
- `sync-main.yml` opens a promotion PR from `dev` to `main`. Merging it mints the next patch tag and `release.yml` builds, scans (Trivy, fixable CRITICAL blocks the push) and pushes.
- Label the promotion PR `release:minor` or `release:major` to change the bump.
- `rebuild.yml` rebuilds the current release weekly with fresh Alpine packages and re-pushes the same tags.
- `trivy-rescan.yml` rescans the released image weekly (CRITICAL+HIGH).
