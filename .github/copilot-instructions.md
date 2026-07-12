# GitHub Copilot Instructions

Use the repository root `AGENTS.md` as the primary instruction source for
this repository.

For repo-specific wrapper/example completion guidance, also see:

- `ai/terraform-module-completer.md`

When reviewing Terraform changes in this repo, validate at minimum:

1. Any new module under `modules/<name>` has:
   - required module files
   - matching wrapper at `wrappers/<name>`
   - matching example at `examples/<name>`
2. README files match the current module interface and file paths.
3. Wrapper and example `source` paths are correct.
4. All supported input modes are represented in examples when relevant.
5. `terraform fmt -recursive` should be clean.
6. Examples should support `terraform init -backend=false` and
   `terraform validate`.

If `AGENTS.md` and this file differ, follow `AGENTS.md`.
