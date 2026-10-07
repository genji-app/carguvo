# Contributing Guide

Welcome to the `game_engine` project. To maintain code quality and the stability of the bridge system, please adhere to the following rules:

---

## 📐 Architecture

The package is designed using a **Platform-Grouping Facade** pattern:

- **Entry Layer**: `lib/src/in_house_runner/ih_runner.dart` and `lib/src/provider_live_runner/pl_runner.dart`. These widgets automatically select the correct platform implementation.
- **Controller Layer**: `lib/src/in_house_runner/ih_runner_controller.dart`. Provides the interface for interacting with WebViews.
- **Platform Implementations**: Located in `mobile/`, `web/`, and `stub/` subdirectories within each engine module.
- **Bridge Logic/Mixins**: `lib/src/in_house_runner/mixins/`. Contains core logic for bridge communication and WebView enhancements.

---

## 📝 Coding Rules

1.  **Documentation**: All `public` classes, methods, and fields MUST have dartdocs in English clearly describing their purpose.
2.  **Linting**: Must pass `flutter analyze` with zero issues. We follow strict linting rules to ensure consistency.
3.  **Immutability**: Use `@immutable` for data models like `GameHostEvent`.
4.  **Error Handling**:
    *   Avoid generic catches (`catch (e)`). Use `on Exception catch (e, st)` or `on Object catch (e, st)`.
    *   Always use `GameEngineLogger` to report errors or warnings.
5.  **Language**:
    *   Public APIs and documentation must be in **English**.
    *   Internal comments should also be in **English** for team standardization.

---

## 🧪 Testing

- **Unit Tests**: Write tests for every new feature in the `test/` directory.
- **Integration Tests**: Verify bridge injection flows in `integration_test/`.
- Run all tests: `flutter test`.

---

## 🔄 Commit Process

Use **Conventional Commits**:
- `feat`: New feature.
- `fix`: Bug fix.
- `docs`: Documentation update.
- `refactor`: Code structure change without logic modification.
- `perf`: Performance improvement.

---
*Major changes must be reviewed by the Team Lead before merging.*
