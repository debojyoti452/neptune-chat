#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/neptune_backend"
APP_DIR="$SCRIPT_DIR/neptune_app"

install_hooks() {
  local hook="$SCRIPT_DIR/.git/hooks/pre-commit"
  if [ ! -f "$hook" ] || ! diff -q "$SCRIPT_DIR/hooks/pre-commit" "$hook" > /dev/null 2>&1; then
    echo "==> Installing git hooks..."
    cp "$SCRIPT_DIR/hooks/pre-commit" "$hook"
    chmod +x "$hook"
    echo "    Git hooks installed."
  fi
}

setup_backend() {
  echo "==> Setting up backend..."
  cd "$BACKEND_DIR"
  mix deps.get
  mix ecto.create
  mix ecto.migrate
  echo "    Backend setup done."
}

run_backend() {
  setup_backend
  echo "==> Starting backend..."
  cd "$BACKEND_DIR"
  mix phx.server
}

setup_app() {
  echo "==> Setting up Flutter app..."
  cd "$APP_DIR"
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  echo "    Flutter app setup done."
}

run_app() {
  setup_app
  echo "==> Starting Flutter app..."
  cd "$APP_DIR"
  flutter run
}

usage() {
  cat <<EOF
Neptune — local dev runner

Usage:
  $0 backend        setup + run Elixir/Phoenix backend
  $0 app            setup + run Flutter app
  $0 setup          setup everything (hooks + backend + app)
  $0 setup backend  setup backend only
  $0 setup app      setup Flutter app only
  $0 setup hooks    install git pre-commit hook

EOF
  exit 1
}

install_hooks

case "${1:-}" in
  backend) run_backend ;;
  app)     run_app ;;
  setup)
    case "${2:-all}" in
      backend) setup_backend ;;
      app)     setup_app ;;
      hooks)   ;;
      all)     setup_backend; setup_app ;;
      *)       usage ;;
    esac
    ;;
  *) usage ;;
esac
