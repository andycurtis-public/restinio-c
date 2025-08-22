## 08/22/2025

**Modernize Restinio C Library build system, licensing, and tests**

---

## Summary

This PR updates the **Restinio C Library** with a modern, variant-aware CMake build, unified tooling, updated SPDX licensing headers, clearer documentation, and a new test + coverage framework.

---

## Key Changes

### 🔧 Build & Tooling

* **Removed** legacy changelog/config files:

    * `.changes/*`, `.changie.yaml`, `CHANGELOG.md`, `build_install.sh`.
* **Added** `build.sh`:

    * Commands: `build`, `install`, `coverage`, `clean`.
    * Coverage integration with `llvm-cov`.
* `.gitignore`: added new build dirs (`build-unix_makefiles`, `build-cov`, `build-coverage`).
* **BUILDING.md**:

    * Updated for *Restinio C Library v0.0.1*.
    * Clear local build + install instructions.
    * Explicit dependency setup:

        * `asio`, `expected-lite`, `fmt`, `restinio`.
    * Modern Dockerfile instructions.
* **Dockerfile**:

    * Ubuntu base image with configurable CMake version.
    * Non-root `dev` user.
    * Builds/installs required deps (`asio`, `expected-lite`, `fmt`, `restinio`) and this project.

### 📦 CMake

* Raised minimum version to **3.20**.
* Project renamed to `restinio_c` (underscore convention).
* **Multi-variant builds**:

    * `debug`, `memory`, `static`, `shared`.
    * Umbrella alias: `restinio_c::restinio_c`.
* Coverage toggle (`A_ENABLE_COVERAGE`) and memory profiling define (`_AML_DEBUG_`).
* Dependencies declared via `find_package`:

    * `restinio`, `fmt`, `expected-lite`, `asio`.
* Proper **install/export**:

    * Generates `restinio_cConfig.cmake` + version file.
    * Namespace: `restinio_c::`.

### 📖 Documentation

* **AUTHORS**: updated Andy Curtis entry with GitHub profile.
* **NOTICE**:

    * Simplified attribution:

        * Andy Curtis (2025), Knode.ai (2024–2025).
    * Removed inline BSD restinio license note (still covered by LICENSE.restinio).
* **\_config.yml**: site title clarified to “Restinio C Library”.

### 📝 Source & Headers

* SPDX headers updated:

    * En-dash year ranges (`2024–2025`).
    * Andy Curtis explicitly credited.
    * Knode.ai marked with “technical questions” contact.
* Removed redundant `Maintainer:` lines.
* Consistent `#endif` formatting and trailing newline fixes.
* No functional changes to implementation.

### ✅ Tests

* **`tests/CMakeLists.txt`**:

    * Modernized with variant-aware linking.
    * Defines main executable: `test_restinio`.
    * Coverage aggregation with `llvm-profdata` + `llvm-cov` (HTML + console).
* **`tests/build.sh`**:

    * Supports variants (`debug|memory|static|shared|coverage`).
    * Auto job detection.
* Test source (`test_restinio.c`):

    * SPDX/licensing headers updated.
    * Code unchanged except cleanup.

---

## Impact

* 🚀 Simplified builds with a single script and modern CMake variants.
* 🛡️ Consistent SPDX licensing across all files.
* 📖 Documentation and NOTICE clarified.
* ✅ Variant-aware tests + coverage ready for CI.
