---
name: complete-module
description: >-
  Complete a Terraform module in this terraform-aws-modules repo by scaffolding its
  matching wrapper under wrappers/<name> and example under examples/<name>, updating
  READMEs after an interface change, and cleaning up source paths after a rename. Matches
  the style of existing wrappers/examples rather than inventing a new one, then runs
  terraform fmt / init / validate. Use when the user says things like "complete module X",
  "scaffold the wrapper and example for module X", "add a wrapper/example for module X",
  or asks to align wrappers/examples/READMEs after editing a module's interface.
---

# Terraform Module Completer

Use this guide when working on a module in this repository that needs:

- a matching wrapper under `wrappers/<name>`
- a matching example under `examples/<name>`
- README updates after a module interface change
- source-path cleanup after a rename

This guide is repository-specific. Follow `AGENTS.md` as the source of
truth.

## Workflow

1. Identify the target module name from `modules/<name>`.
2. Read the target module:
   - `main.tf`
   - `variables.tf`
   - `outputs.tf`
   - `README.md`
3. Read `AGENTS.md`.
4. Inspect the most similar existing wrapper and example already present
   in this repository.
5. Create or update:
   - `wrappers/<name>/`
   - `examples/<name>/`
   - related README references if paths or names changed

## Wrapper Rules

For `wrappers/<name>`:

1. Match the style and format of the existing wrappers in this repo.
2. Source `../../modules/<name>`.
3. Expose `defaults` and `items`.
4. Pass through supported module inputs using the same style used in the
   existing wrappers in this repo.
5. Include:
   - `main.tf`
   - `variables.tf`
   - `outputs.tf`
   - `versions.tf`
   - `README.md`

## Example Rules

For `examples/<name>`:

1. Match the style and format of the existing examples in this repo.
2. Source `../../modules/<name>`.
3. Cover all important supported input modes.
4. If the module supports mutually exclusive inputs, alternate lookup
   paths, or validation behavior, show each supported path in the
   example.
5. Include:
   - `main.tf`
   - `README.md`

## README Rules

1. Keep README paths aligned with the current module name.
2. Keep wrapper README structure aligned with other wrappers in this
   repo.
3. Keep example README short and accurate.
4. Do not leave stale names after renames.

## Validation

After writing or updating wrapper/example files:

1. Run:

```bash
terraform fmt -recursive
```

2. Run init/validate for the relevant example:

```bash
terraform -chdir=examples/<name> init -backend=false
terraform -chdir=examples/<name> validate
```

3. If the module uses data sources that require real infrastructure,
   prefer an example path that can still validate when possible. If not
   possible, document the runtime dependency clearly in the example
   README.

## Output Standard

Do not invent a new wrapper or example style for this repository.

Prefer copying the structure of the closest existing wrapper and example,
then adapting only the parts required by the module interface.
</content>
</invoke>
