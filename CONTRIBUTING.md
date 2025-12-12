# Contributing

Thanks for your interest in improving these Terraform modules for Cloudflare! This guide explains the development workflow, coding style, tests, and the review process we follow.

## Prerequisites

- Terraform 1.14.1 (preferred) or >= 1.5.0 on PATH
- Optional: [`mise`](https://github.com/jdx/mise) to activate pinned tool versions defined in `mise.toml`
- No Cloudflare credentials are required for running tests (they use plan‑time only). Applying examples to a real account does require credentials.

Quick start with pinned tools:

```bash
mise install
mise run fmt
```

## Project structure

- `modules/*`: self‑contained Terraform modules with native tests in `tests/*.tftest.hcl`.
- `examples/complete`: example composition for manual plan/apply.
- `mise.toml`: shortcuts for fmt/init/validate/plan and running all module tests.

## Coding style

Keep changes minimal and consistent with the existing codebase.

- Formatting:
  - Run `mise run fmt` (or `terraform fmt -recursive`) before committing.
- Terraform versions:
  - Modules: keep `required_version` at `>= 1.5.0` unless there is a repo‑wide bump.
  - Example/root: currently targets Terraform 1.14 syntax; if you adopt newer language features, update version constraints consistently.
- Providers:
  - Each module pins providers in its `versions.tf`. Cloudflare provider is `>= 5.0.0`; tests currently resolve to ~5.14.0. Do not opportunistically bump—coordinate provider changes with tests.
- Structure and naming:
  - Maintain the standard module files: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `README.md`, and `tests/`.
  - Follow existing variable names, types, and descriptions; prefer explicit types and defaults when appropriate.
- Comments and docs:
  - Mirror the existing style and density of comments. Update module `README.md` when inputs/outputs/behavior change.

## Tests (Terraform native test framework)

All modules use Terraform native tests (`.tftest.hcl`) that assert plan‑time attributes. Tests must pass for PRs to be considered.

- Run all module tests:
  - `mise run test`
- Run tests for a single module:
  - `terraform -chdir=modules/<module> init -backend=false -upgrade`
  - `terraform -chdir=modules/<module> test -verbose`
- Writing tests:
  - Place new tests in `modules/<module>/tests/*.tftest.hcl`.
  - Prefer `command = plan` with assertions against resource attributes.
  - Use stable dummy IDs and values (e.g., `zone_12345`, `acc_12345`) to avoid provider validation and network calls.
  - For map/for_each resources, index with predictable keys.
  - Add multiple `run` blocks to cover branches; each runs with isolated state.

## Local validation and examples

If you change the example composition in `examples/complete`:

- `mise run init`
- `mise run validate`
- `mise run plan`

Only run `apply` against a safe, non‑production account after review and with valid Cloudflare credentials. Never commit real state.

## Commit messages

Use clear, conventional commits where possible. Examples:

- `feat(workers): add option to create wildcard route`
- `fix(origin-ca): correct requested_validity default in docs`
- `test(traffic-rules): assert action for challenge mode`
- `chore: terraform fmt and README tweaks`

Reference related issues with `Fixes #123` or `Refs #123` when applicable.

## Pull request process

1. Ensure the code is formatted: `mise run fmt`.
2. Ensure all module tests pass locally:
   - Prefer `mise run test`; or run per‑module as shown above.
3. Update documentation:
   - Module `README.md` for any new inputs/outputs/behavior.
   - `CHANGELOG.md` entry if the change is user‑facing; use Keep a Changelog style.
4. Keep PRs focused and small. If a change spans multiple modules, consider separate PRs per module.
5. Link related issues and provide a brief rationale in the PR description.

## Review checklist (what maintainers look for)

- Tests:
  - [ ] New/changed behavior is covered by `.tftest.hcl` plan assertions.
  - [ ] All module tests pass locally and in CI.
- Style and consistency:
  - [ ] Code formatted with `terraform fmt`.
  - [ ] Variable names, types, and outputs align with existing conventions.
  - [ ] No unnecessary provider or version bumps.
- Documentation:
  - [ ] Module README updated (inputs/outputs/examples) as needed.
  - [ ] Changelog updated for user‑facing changes.
- Safety:
  - [ ] No accidental state files or credentials committed.
  - [ ] Cloudflare resources that are not destroyable (e.g., certain settings) are handled via plan‑only tests.

## Releasing

Maintainers will update `CHANGELOG.md` and tag releases once changes are merged. If your change requires a version bump or a release note, mention it in the PR.

## Questions

If anything is unclear or you need guidance on tests or provider nuances, open a draft PR or start a discussion in the issue. We appreciate your contributions!
