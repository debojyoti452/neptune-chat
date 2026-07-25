# Contributing to Neptune

Thank you for your interest in contributing to Neptune. This document covers the process and standards for contributing to both the Flutter app and the Elixir backend.

---

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone git@github.com:<your-handle>/neptune-monorepo.git`
3. Set up both projects following the [README](README.md#getting-started)
4. Create a feature branch: `git checkout -b feat/your-feature`

---

## Project Structure

Refer to [docs/codebase.md](docs/codebase.md) for the full annotated file tree and [docs/architecture.md](docs/architecture.md) for system design before making changes.

---

## Backend (Elixir/Phoenix)

### Setup

```sh
cd neptune_backend
mix setup
```

### Before Every Commit

```sh
mix precommit   # compile + format + unused dep check + test
```

This must pass with zero warnings and zero failures.

### Running Tests

```sh
mix test
```

### Code Standards

- Follow existing Phoenix context boundaries - `Auth`, `Accounts`, `Relay`, `Signaling` are separate contexts
- No business logic in controllers or plugs - controllers delegate to contexts only
- Pure-Elixir crypto only - no NIFs, no C dependencies
- All public functions documented with `@doc` and `@spec`
- No inline code comments

---

## Flutter App (Dart/Flutter)

### Setup

```sh
cd neptune_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Before Every Commit

```sh
dart analyze lib    # must be clean
flutter test        # must pass
```

### Code Standards

- Clean Architecture strictly enforced:
  - Domain layer - pure Dart only, zero Flutter or package imports
  - Presentation layer - calls UseCases only, never Datasources directly
  - Data layer - maps Models to/from domain Entities
- Use `Freezed` for all events, states, models, and value objects
- Use `Equatable` for domain entities
- No inline code comments
- No plaintext data in any local storage - SQLCipher for all structured data
- No hardcoded secrets or API keys - use `--dart-define` at build time

### Regenerating Code

After modifying any `@freezed`, `@JsonSerializable`, or `@injectable` annotated class:

```sh
dart run build_runner build --delete-conflicting-outputs
```

---

## Pull Request Guidelines

- Keep PRs focused - one feature or fix per PR
- Write a clear PR description explaining what changed and why
- Ensure `mix precommit` and `dart analyze lib` both pass before opening a PR
- Do not push generated files if only logic changed - regenerate and include them

---

## Security

- Never commit private keys, tokens, or secrets
- Never add plaintext storage for any user data
- All chat content must be E2E encrypted before leaving the device
- Report security vulnerabilities privately before opening a public issue

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
