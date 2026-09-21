# syntax=docker/dockerfile:1.7
# -----------------------------------------------------------------------------
# WMS web (Vite + React + TypeScript, web/) -> static bundle served by nginx.
#
# Build context is the web/ directory (npm project root). Three things the build needs
# live outside it, so they are passed as additional named build contexts:
#   deploy        -> deploy/docker          (nginx.conf for the runtime stage)
#   contracts     -> contracts/openapi      (npm run gen:api, ADR-007)
#   designsystem  -> docs/design-system     (npm run gen:tokens, ADR-011)
#
#   docker build -f deploy/docker/web.Dockerfile \
#     --build-context deploy=deploy/docker \
#     --build-context contracts=contracts/openapi \
#     --build-context designsystem=docs/design-system \
#     --build-arg VITE_API_BASE_URL= \
#     --build-arg VITE_KEYCLOAK_ISSUER=https://auth.example.com/realms/wms \
#     -t wms/web web
# (docker compose does this via build.additional_contexts.)
#
# The container mirrors the repo layout the generator scripts expect: web/ is /app, so
# `resolve(here, '../../contracts/openapi')` lands on /contracts/openapi.
#
# Vite inlines `import.meta.env.VITE_*` at build time, so the three VITE_ args
# below are baked into the bundle - they are public values (ADR-009: the OIDC
# client is public, Authorization Code + PKCE, no secret).
#
# VITE_API_BASE_URL MUST stay EMPTY for this image. Each generated client already carries the
# `/api/v1/<module>` prefix from its spec's servers[0].url (web/src/api/client.ts), so an empty
# base means same-origin `/api/v1/...` requests, which nginx forwards to the gateway. Setting it
# to `/api` produces `/api/api/v1/...` (404) and setting it to an absolute URL produces
# cross-origin requests the gateway rejects - it sends no CORS headers.
#
# Runtime args (env): API_UPSTREAM=gateway:8080  -> nginx proxies /api/ there
#                     DNS_RESOLVER              -> auto-detected from /etc/resolv.conf
#                     CSP_POLICY                -> optional Content-Security-Policy value
# -----------------------------------------------------------------------------
ARG NODE_IMAGE=node:22-alpine
ARG NGINX_IMAGE=nginxinc/nginx-unprivileged:stable-alpine

# ---- 1. deps: only the lockfile manifests, so `npm ci` is cacheable ----
FROM ${NODE_IMAGE} AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,id=npm,target=/root/.npm,sharing=locked \
    npm ci

# ---- 2. build ----
FROM ${NODE_IMAGE} AS build
ARG VITE_API_BASE_URL=
ARG VITE_KEYCLOAK_ISSUER=http://localhost:8080/realms/wms
ARG VITE_KEYCLOAK_CLIENT_ID=wms-web
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL} \
    VITE_KEYCLOAK_ISSUER=${VITE_KEYCLOAK_ISSUER} \
    VITE_KEYCLOAK_CLIENT_ID=${VITE_KEYCLOAK_CLIENT_ID}
WORKDIR /app

# Source first, then the Linux node_modules on top. web/.dockerignore keeps the host's
# macOS node_modules, dist/, caches and .env out of the context; the copy order is kept as a
# second line of defence so the deps stage always wins.
COPY . .
COPY --from=deps /app/node_modules ./node_modules

# Sources that live outside web/, placed where the generator scripts resolve them.
COPY --from=contracts . /contracts/openapi
COPY --from=designsystem . /docs/design-system

# The OpenAPI types are git-ignored (ADR-007), so a clean checkout has none - generate
# them first. `npm run build` then runs gen:tokens + tsc -b --noEmit + vite build.
RUN npm run gen:api && npm run build

# ---- 3. runtime: nginx (unprivileged flavour of nginx:alpine - same upstream, runs as uid 101 on :8080) ----
FROM ${NGINX_IMAGE} AS runtime
ENV API_UPSTREAM=gateway:8080 \
    DNS_RESOLVER="" \
    CSP_POLICY=""

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

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz >/dev/null || exit 1
