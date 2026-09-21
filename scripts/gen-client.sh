#!/usr/bin/env bash
# gen-client.sh — contracts/openapi/<module>.v1.yaml  →  Dart (dart-dio) client
#
# Usage:
#   scripts/gen-client.sh                       # all modules
#   scripts/gen-client.sh inventory procurement # selected modules
#   GEN_OUT_DIR=/tmp/gen scripts/gen-client.sh  # alternative output root (CI proof-of-generation)
#   OPENAPI_GENERATOR_IMAGE=openapitools/openapi-generator-cli:v7.14.0 scripts/gen-client.sh
#
# Output (gitignored, see .gitignore):
#   mobile/packages/wms_api_client/lib/src/generated/<module>/
#
# Requires Docker only — no local Java / openapi-generator install.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_DIR="$ROOT_DIR/contracts/openapi"
OUT_DIR="${GEN_OUT_DIR:-$ROOT_DIR/mobile/packages/wms_api_client/lib/src/generated}"
IMAGE="${OPENAPI_GENERATOR_IMAGE:-openapitools/openapi-generator-cli:latest}"
ALL_MODULES=(identity masterdata inventory procurement documents notifications reporting)

MODULES=("$@")
if [ ${#MODULES[@]} -eq 0 ]; then
  MODULES=("${ALL_MODULES[@]}")
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is required (see docs/CONVENTIONS.md)" >&2
  exit 1
fi

# On Linux run the generator as the current user so generated files are not root-owned.
# (Docker Desktop on macOS/Windows already maps ownership.)
DOCKER_USER=()
if [ "$(uname -s)" = "Linux" ]; then
  DOCKER_USER=(-u "$(id -u):$(id -g)")
fi

mkdir -p "$OUT_DIR"

for module in "${MODULES[@]}"; do
  spec="$SPEC_DIR/$module.v1.yaml"
  if [ ! -f "$spec" ]; then
    echo "error: spec not found: $spec (known modules: ${ALL_MODULES[*]})" >&2
    exit 1
  fi

  target="$OUT_DIR/$module"
  rm -rf "$target"
  mkdir -p "$target"
  echo "==> $module.v1.yaml  ->  ${target#"$ROOT_DIR"/}"

  # common.v1.yaml is resolved through the ./common.v1.yaml $refs because the whole
  # openapi/ directory is mounted read-only at /spec.
  docker run --rm ${DOCKER_USER[@]+"${DOCKER_USER[@]}"} \
    -v "$SPEC_DIR:/spec:ro" \
    -v "$target:/out" \
    "$IMAGE" generate \
      -g dart-dio \
      -i "/spec/$module.v1.yaml" \
      -o /out \
      --additional-properties=pubName=wms_api_generated,pubLibrary=wms_api_generated."$module",nullableFields=true,serializationLibrary=built_value,pubVersion=1.0.0 \
      --global-property=apiTests=false,modelTests=false,apiDocs=false,modelDocs=false \
      --skip-operation-example \
      >"$target/.generator.log" 2>&1 || {
        echo "error: generation failed for $module — see $target/.generator.log" >&2
        tail -n 40 "$target/.generator.log" >&2
        exit 1
      }

  models=$(find "$target/lib/src/model" -name '*.dart' 2>/dev/null | wc -l | tr -d ' ')
  apis=$(find "$target/lib/src/api" -name '*.dart' 2>/dev/null | wc -l | tr -d ' ')
  echo "    models: $models, apis: $apis"
done

cat <<'NOTE'

Post-generation notes (read before wiring the client):
  1. DECIMALS ARE STRINGS ON PURPOSE. Every quantity/amount/rate/percent field is generated as
     Dart `String` (contracts/openapi/common.v1.yaml#/components/schemas/Decimal). The mapping
     layer in wms_api_client MUST convert them with `Decimal.parse(...)` (package:decimal) into
     wms_core `Quantity` / `Money` — never `double.parse`, never `num` (ADR-008).
  2. built_value needs codegen after generation:
       cd mobile/packages/wms_api_client && dart run build_runner build --delete-conflicting-outputs
  3. Generated sources are gitignored; CI and developers regenerate with `make gen-client`.
  4. Each module is generated under the same pubName (wms_api_generated) but a distinct
     pubLibrary (wms_api_generated.<module>) so the `serializers.dart` of one module does not
     collide with another when both are imported into wms_api_client.
NOTE
