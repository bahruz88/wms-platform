# syntax=docker/dockerfile:1.7
# -----------------------------------------------------------------------------
# WMS backend image - ONE Dockerfile for every .NET host (docs/CONVENTIONS.md):
#   HOST_PROJECT = Wms.Host.Api        -> src/Host/Wms.Host.Api        (default)
#                | Wms.Host.Migrator   -> src/Host/Wms.Host.Migrator   (run-once EF migrations)
#                | Wms.Gateway         -> src/Gateway/Wms.Gateway      (YARP)
#
# Build context is the backend/ directory:
#   docker build -f deploy/docker/backend.Dockerfile --build-arg HOST_PROJECT=Wms.Gateway -t wms/gateway backend
#
# Multi-arch: the SDK stages always run natively on the build host ($BUILDPLATFORM)
# and cross-compile for $TARGETARCH; only the runtime stage is pulled for the
# target platform.  `docker buildx build --platform linux/amd64,linux/arm64 ...`
# -----------------------------------------------------------------------------
ARG DOTNET_VERSION=10.0

# ---- 1. prep: mirror only restore-relevant files so `dotnet restore` is cacheable ----
# The csproj list changes rarely; copying the whole tree here and filtering with
# `find` keeps the Dockerfile independent of the exact project layout.
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS prep
WORKDIR /src
COPY . .
RUN mkdir -p /restore && find . -type f \( \
        -name '*.csproj' -o -name '*.props' -o -name '*.targets' \
        -o -name '*.slnx' -o -name '*.sln' -o -name 'global.json' \
        -o -name 'nuget.config' -o -name 'NuGet.Config' -o -name 'packages.lock.json' \
      \) -not -path '*/bin/*' -not -path '*/obj/*' \
      -exec cp --parents '{}' /restore \;

# ---- 2. build / publish ----
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
ARG HOST_PROJECT=Wms.Host.Api
ARG TARGETARCH
ARG BUILD_CONFIGURATION=Release
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
    NUGET_XMLDOC_MODE=skip
WORKDIR /src

# restore layer: only invalidated when a csproj/props/lock file changes
COPY --from=prep /restore .
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages,sharing=locked \
    set -eu; \
    PROJ="$(find src -type f -name "${HOST_PROJECT}.csproj" | head -n 1)"; \
    test -n "$PROJ" || { echo "ERROR: ${HOST_PROJECT}.csproj not found under src/ (expected src/Host/* or src/Gateway/*)"; exit 1; }; \
    echo "restoring $PROJ for linux-$TARGETARCH"; \
    dotnet restore "$PROJ" -a "$TARGETARCH"

# full source
COPY . .
RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages,sharing=locked \
    set -eu; \
    PROJ="$(find src -type f -name "${HOST_PROJECT}.csproj" | head -n 1)"; \
    dotnet publish "$PROJ" \
        -c "$BUILD_CONFIGURATION" -a "$TARGETARCH" --no-restore \
        -o /app \
        /p:UseAppHost=false \
        /p:DebugType=embedded \
        /p:GenerateDocumentationFile=false

# ---- 3. runtime ----
FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS runtime
ARG HOST_PROJECT=Wms.Host.Api
ENV HOST_PROJECT=${HOST_PROJECT} \
    ASPNETCORE_URLS=http://+:8080 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    TZ=UTC
WORKDIR /app
COPY --from=build /app .

# Resolves the host assembly from HOST_PROJECT and passes any args through
# (e.g. `--Modules=inventory`), so a single image serves every host.
#
# CONSTRAINT on configuration env vars: this entrypoint is a /bin/sh (dash) script, and dash rebuilds the
# child environment from its own variable table, silently dropping every name that is not a valid shell
# identifier. So `-e 'Section__some-key__Value=x'` reaches the container but NEVER reaches .NET, while
# `-e 'Section__some_key__Value=x'` does. Keep every overridable configuration key to [A-Za-z0-9_]
# (this is why the YARP cluster ids in Wms.Gateway/appsettings.json are `identity`, not `wms-identity`).
COPY --chmod=755 <<'ENTRYPOINT_SH' /app/entrypoint.sh
#!/bin/sh
set -eu
exec dotnet "/app/${HOST_PROJECT}.dll" "$@"
ENTRYPOINT_SH

# non-root (uid 1654 `app`, shipped by the aspnet image)
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
