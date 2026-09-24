---
name: complete-module
description: >-
  Complete a Terraform module in this terraform-aws-modules repo by scaffolding its
  matching wrapper under wrappers/<name>, example under examples/<name>, and tests under
  modules/<name>/tests, updating READMEs after an interface change, and cleaning up source
  paths after a rename. Matches the style of existing wrappers/examples rather than
  inventing a new one, then runs terraform fmt / init / validate / test. Use when the user says things like "complete module X",
  "scaffold the wrapper and example for module X", "add a wrapper/example for module X",
  or asks to align wrappers/examples/READMEs after editing a module's interface.
---

# Terraform Module Completer

Use this guide when working on a module in this repository that needs:

- a matching wrapper under `wrappers/<name>`
- a matching example under `examples/<name>`
- matching tests under `modules/<name>/tests`
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
   - `modules/<name>/tests/`
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

## Test Rules

For `modules/<name>/tests`:

1. Use `mock_provider "aws"` so tests never touch a real account, and
   `override_data` for every data source the module reads.
2. Mock `aws_iam_openid_connect_provider` with a syntactically valid
   `arn`; the module splits it on `oidc-provider/` to derive the trust
   policy condition keys, and a generated mock value fails at plan time.
3. Give every `validation` block in `variables.tf` a rejected case in
   `validations.tftest.hcl`, plus the boundary cases that must be
   accepted.
4. Compare collection-typed attributes against `tolist([...])`,
   `toset([...])` or `tomap({...})`; a bare literal fails the type check.
5. Assert on decoded policy documents (`jsondecode(...)`), not on the
   rendered JSON string.

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

2. Run the module tests:

```bash
terraform -chdir=modules/<name> init -backend=false
terraform -chdir=modules/<name> test
```

3. Run init/validate for the relevant example. Examples reference the
   published registry source, so copy the example and rewrite the source
   to the local module path first, the way the `inits` workflow job does:

```bash
terraform -chdir=examples/<name> init -backend=false
terraform -chdir=examples/<name> validate
```

4. If the module uses data sources that require real infrastructure,
   prefer an example path that can still validate when possible. If not
   possible, document the runtime dependency clearly in the example
   README.

## Output Standard

Do not invent a new wrapper or example style for this repository.

Prefer copying the structure of the closest existing wrapper and example,
then adapting only the parts required by the module interface.
</content>
</invoke>
