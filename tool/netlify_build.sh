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

if [[ -n "${PLAUSIBLE_DOMAIN:-}" ]]; then
  if [[ ! "${PLAUSIBLE_DOMAIN}" =~ ^[A-Za-z0-9.-]+$ ]]; then
    echo "PLAUSIBLE_DOMAIN contains unsupported characters." >&2
    exit 1
  fi
  python3 - "${PLAUSIBLE_DOMAIN}" <<'PY'
from pathlib import Path
import sys

domain = sys.argv[1]
index = Path("build/web/index.html")
html = index.read_text(encoding="utf-8")
tag = (
    f'<script defer data-domain="{domain}" '
    'src="https://plausible.io/js/script.js"></script>'
)
index.write_text(html.replace("</head>", f"  {tag}\n</head>"), encoding="utf-8")
PY
fi
