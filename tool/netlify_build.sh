#!/usr/bin/env bash

set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.35.6}"
CACHE_ROOT="${NETLIFY_CACHE_DIR:-${HOME}/.cache/netlify}"
FLUTTER_ROOT="${CACHE_ROOT}/flutter/${FLUTTER_VERSION}"

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
  mkdir -p "$(dirname "${FLUTTER_ROOT}")"
  git clone \
    --depth 1 \
    --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git \
    "${FLUTTER_ROOT}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"

flutter config --no-analytics
flutter pub get

build_args=(web --release --no-wasm-dry-run)
if [[ -n "${CHARTER_API_BASE_URL:-}" ]]; then
  build_args+=(
    --dart-define="CHARTER_API_BASE_URL=${CHARTER_API_BASE_URL}"
  )
fi

flutter build "${build_args[@]}"
