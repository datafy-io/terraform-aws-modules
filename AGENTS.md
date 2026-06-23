# Repo Instructions

This repository contains Terraform modules, wrappers, and examples for
the AWS infrastructure Datafy provisions. It currently covers IAM roles,
and will grow to include other AWS modules Datafy creates over time.

## Source of Truth

This file is the authoritative instruction set for AI assistants working
in this repository.

If another repo-local instruction file exists, treat this file as the
source of truth and keep the other file aligned with it.

## Repository Contract

When a developer adds a new module under `modules/<name>`, review for all
of the following:

1. Required module files exist:
   - `main.tf`
   - `variables.tf`
   - `outputs.tf`
   - `versions.tf`
   - `README.md`
2. A matching wrapper exists at `wrappers/<name>`.
3. A matching example exists at `examples/<name>`.
4. Module, wrapper, example, and root README paths are consistent after
   any rename.
5. `terraform fmt -recursive` is clean.
6. Each example supports `terraform init -backend=false`.
7. Each example supports `terraform validate`.
8. README content matches the actual module interface and current file
   paths.

## Wrapper Rules

For each module wrapper under `wrappers/<name>`:

1. The wrapper name must match the module name exactly.
2. The wrapper must source `../../modules/<name>`.
3. The wrapper format and style should follow the closest existing
   wrapper already present in this repository.
4. The wrapper must expose:
   - `defaults`
   - `items`
5. The wrapper must include:
   - `main.tf`
   - `variables.tf`
   - `outputs.tf`
   - `versions.tf`
   - `README.md`
6. The wrapper README should include:
   - `Usage with Terragrunt`
   - `Usage with Terraform`
   - a concrete example when useful

## Example Rules

For each example under `examples/<name>`:

1. The example must source `../../modules/<name>`.
2. The example format and style should follow the closest existing
   example already present in this repository.
3. The example must demonstrate all important supported input modes for
   the module.
4. If a module supports mutually exclusive inputs or multiple resolution
   paths, the example should show each supported path.
5. The example README must accurately describe what the example covers.

## Reusable Guidance

If completing a new module, use the repository-local skill:

- `.claude/skills/complete-module/SKILL.md` (invoke as `/complete-module`)

That skill should be used to derive wrappers and examples from the
module interface while preserving this repository's existing wrapper and
example style.

## Review Focus

When reviewing new module changes, prioritize:

1. Missing wrapper or missing example.
2. README drift after rename or interface change.
3. Example coverage gaps for supported options.
4. Incorrect relative source paths.
5. Terraform validation issues.

## Naming Rules

1. Keep module, wrapper, and example names aligned exactly.
2. Prefer explicit, intention-revealing names over generic names when
   the module is purpose-built.
3. After any rename, update:
   - root `README.md`
   - module README
   - wrapper README
   - example README
   - all Terraform `source` references

## Validation Commands

Use these commands when checking repo consistency:

```bash
terraform fmt -recursive
terraform -chdir=examples/iam-role init -backend=false
terraform -chdir=examples/iam-role validate
terraform -chdir=examples/iam-role-for-datafy-controller-eks init -backend=false
terraform -chdir=examples/iam-role-for-datafy-controller-eks validate
```

If more examples are added, extend validation to each `examples/*`
subdirectory.
