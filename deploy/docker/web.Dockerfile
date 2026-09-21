# syntax=docker/dockerfile:1.7
# -----------------------------------------------------------------------------
# WMS web (Flutter, apps/wms_web) -> static bundle served by nginx.
#
# Build context is the frontend/ directory (pub workspace root). The nginx config
# lives in deploy/docker, outside that context, so it is passed as an additional
# named build context called "deploy":
#   docker build -f deploy/docker/web.Dockerfile --build-context deploy=deploy/docker \
#     --build-arg API_BASE_URL=/api \
#     --build-arg KEYCLOAK_ISSUER=https://auth.example.com/realms/wms \
#     -t wms/web frontend
# (docker compose does this via build.additional_contexts.)
#
# Runtime args (env): API_UPSTREAM=gateway:8080  -> nginx proxies /api/ there
#                     DNS_RESOLVER              -> auto-detected from /etc/resolv.conf
# -----------------------------------------------------------------------------
ARG FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable
ARG NGINX_IMAGE=nginxinc/nginx-unprivileged:stable-alpine

# ---- 1. prep: only pubspec manifests, so `flutter pub get` is cacheable ----
FROM ${FLUTTER_IMAGE} AS prep
WORKDIR /workspace
COPY . .
RUN mkdir -p /manifests && find . -type f \( \
        -name 'pubspec.yaml' -o -name 'pubspec.lock' -o -name 'melos.yaml' -o -name 'pubspec_overrides.yaml' \
      \) -not -path '*/.dart_tool/*' -not -path '*/build/*' \
      -exec cp --parents '{}' /manifests \;

# ---- 2. build ----
FROM ${FLUTTER_IMAGE} AS build
ARG API_BASE_URL=/api
ARG KEYCLOAK_ISSUER=http://localhost:8080/realms/wms
ARG KEYCLOAK_CLIENT_ID=wms-web
ENV PUB_CACHE=/root/.pub-cache
WORKDIR /workspace

# dependency layer
COPY --from=prep /manifests .
RUN --mount=type=cache,id=pub,target=/root/.pub-cache,sharing=locked \
    flutter --version && flutter pub get

# full source + release build of the web app
COPY . .
RUN --mount=type=cache,id=pub,target=/root/.pub-cache,sharing=locked \
    flutter pub get && \
    cd apps/wms_web && \
    flutter build web --release \
      --dart-define=API_BASE_URL="${API_BASE_URL}" \
      --dart-define=KEYCLOAK_ISSUER="${KEYCLOAK_ISSUER}" \
      --dart-define=KEYCLOAK_CLIENT_ID="${KEYCLOAK_CLIENT_ID}"

# ---- 3. runtime: nginx (unprivileged flavour of nginx:alpine - same upstream, runs as uid 101 on :8080) ----
FROM ${NGINX_IMAGE} AS runtime
ENV API_UPSTREAM=gateway:8080 \
    DNS_RESOLVER=""

# nginx.conf is an envsubst template (official image feature: /etc/nginx/templates/*.template)
COPY --from=deploy nginx.conf /etc/nginx/templates/default.conf.template

# Picks the container's DNS server for nginx's `resolver` (Docker 127.0.0.11, k8s kube-dns)
# unless DNS_RESOLVER is given. *.envsh files are sourced by the official entrypoint.
COPY --chmod=755 <<'RESOLVER_SH' /docker-entrypoint.d/05-resolver.envsh
#!/bin/sh
if [ -z "${DNS_RESOLVER:-}" ]; then
  DNS_RESOLVER="$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf 2>/dev/null || true)"
  [ -n "$DNS_RESOLVER" ] || DNS_RESOLVER=127.0.0.11
  export DNS_RESOLVER
fi
RESOLVER_SH

COPY --from=build /workspace/apps/wms_web/build/web /usr/share/nginx/html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz >/dev/null || exit 1
