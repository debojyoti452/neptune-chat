#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/neptune_backend"
APP_DIR="$SCRIPT_DIR/neptune_app"

clean_backend() {
  echo "==> Cleaning backend..."
  cd "$BACKEND_DIR"
  mix clean
  rm -rf _build deps
  rm -f priv/*.db priv/*.db-shm priv/*.db-wal
  echo "    Backend clean done."
  echo "==> Restoring backend..."
  mix deps.get
  mix ecto.create
  mix ecto.migrate
  echo "    Backend restore done."
}

clean_app() {
  echo "==> Cleaning Flutter app..."
  cd "$APP_DIR"
  flutter clean
  find lib -name "*.freezed.dart" -delete
  find lib -name "*.g.dart" -delete
  find lib -name "injection.config.dart" -delete
  echo "    Flutter app clean done."
  echo "==> Restoring Flutter app..."
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  echo "    Flutter app restore done."
}

install_hooks() {
  local hook="$SCRIPT_DIR/.git/hooks/pre-commit"
  if [ ! -f "$hook" ] || ! diff -q "$SCRIPT_DIR/hooks/pre-commit" "$hook" > /dev/null 2>&1; then
    echo "==> Installing git hooks..."
    cp "$SCRIPT_DIR/hooks/pre-commit" "$hook"
    chmod +x "$hook"
    echo "    Git hooks installed."
  fi
}

install_hooks

case "${1:-all}" in
  backend) clean_backend ;;
  app)     clean_app ;;
  all)     clean_backend; clean_app ;;
  *)
    echo "Usage: $0 [backend|app|all]"
    exit 1
    ;;
esac
