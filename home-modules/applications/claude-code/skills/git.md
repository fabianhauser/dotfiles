---
name: git
description: Git commit and branch conventions. Always use when performing any git operation, creating commits, naming branches, or working with git history.
---

## Commit Messages

Keep commit messages short and in **present simple** tense. No conventional-commits prefixes (`feat:`, `fix:`, `chore:`, etc.) and no scoped prefixes (`feat(scope):`).

Good examples:

- `Add claude skill for git`
- `Fix commit message description in nix skill`
- `Move claude-code config into folder module`
- `Update statusline to show weekly usage`

Only add a body (after two blank lines) when there is non-obvious or complex context that would not be clear from the diff.

## Branch Names

Use short, descriptive kebab-case names. No `feat/`, `fix/`, `chore/`, or other type prefixes — unless the project's `CLAUDE.md` explicitly specifies a branch naming convention.

Good examples:

- `claude-nix-skill`
- `statusline-weekly-usage`
- `disko-ochsenchopf`

## Fixing Bugs After Committing (git absorb)

When you have already committed some work and then find a bug in an earlier commit, use `git absorb` instead of creating a separate fixup commit manually:

1. Stage the fix with `git add` (or `git add -p` for partial staging)
1. Run:
   ```bash
   git absorb --and-rebase
   ```

`git absorb` inspects the staged changes, determines which earlier commit they belong to, and creates fixup commits. `--and-rebase` then automatically runs `git rebase --autosquash` to fold them in, rewriting history cleanly.

If `git absorb` cannot determine the target commit unambiguously, it will tell you — in that case create a manual fixup commit and rebase yourself.
