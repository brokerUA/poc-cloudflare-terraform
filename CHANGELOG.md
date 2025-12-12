# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [0.2.0] - 2025-12-12

Reason for version bump: user-facing improvements to the `origin-ca` module (CSR generation) and an input removal. Prior to 1.0, breaking changes increment the minor version.

### Added

- origin-ca: CSR generation logic to simplify certificate creation workflows (5b85216)

### Changed

- Tooling: update pinned tool versions in `mise.toml` (9c3a0d9)
- Examples/docs: refreshed examples and documentation to match current module behavior (5b85216)

### Removed

- origin-ca: removed `account_id` input (9c3a0d9)

### Chore

- Add `.markdownlint.json` and apply linting tweaks (5b85216)
- Remove unused `.terraform.lock.hcl` files (9c3a0d9)

### Merged

- Merge PR #2 (40e72d7)

## [0.1.0] - 2025-12-12

First pre-release of the Terraform modules for Cloudflare. This version captures the initial module set and housekeeping changes.

### Added

- Reusable Terraform modules for Cloudflare configuration: `zone-baseline`, `workers`, `traffic-rules`, and `origin-ca` (83dd2f8)
- LICENSE and .gitignore (d4d589f)

### Changed

- Tooling and housekeeping: removed unused `.terraform.lock.hcl` files and updated tool versions in `mise.toml` (91bf998)

### Removed

- origin-ca module: removed `account_id` input (91bf998)

### Merged

- Merge PR #1: Add reusable Terraform modules (21555e0)
