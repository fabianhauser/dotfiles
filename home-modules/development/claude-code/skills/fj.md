---
name: fj
description: Forgejo CLI (fj) pull requests on Forgejo remotes like git.qo.is — NOT GitHub, use gh there. TRIGGER when: opening a PR, reading or answering PR review comments, or checking PR CI status on a Forgejo remote, or the user says "fj" or "Forgejo".
---

`fj` is `gh` for Forgejo. Hits the network — run with `dangerouslyDisableSandbox: true`, from inside the repo - outside of the sandbox!
`[ID]` is optional on subcommands acting on an existing PR and defaults to the current branch's PR (errors if there is none).

## Opening a PR

`fj pr create <title> --body-file <file>`, or `-A/--autofill` when the commits already tell the story.
Omitting both `--body` and `--body-file` opens `$EDITOR` and hangs.
Body: don't narrate the diff. Add a `- [ ]` checklist of what the reviewer/deployer must verify
("dashboard renders after deploy", "migration is backward-compatible"), not generics like "CI passes".

## Processing review feedback

- `fj pr view <id> comments` — read feedback
- `fj pr review <id> list` — review state; fj cannot approve or request changes
- `fj pr comment <id> --body-file <file>` — reply
- `fj pr edit <id> title|body <text>` — each is its own subcommand

## Checking a CI failure

- `fj pr status <id> [--wait]` — mergeability + per-check status; `--wait` blocks until checks finish
- `fj` has no log-fetching command — ask the user to paste the failing log, or to open the PR themselves with `fj pr browse` (opens a browser, don't run it yourself)

`fj issue` mirrors `pr` (`search view comment edit create close assign unassign`); `fj pr search [-s open|closed|all] [-l] [-c] [-a] [QUERY]` finds IDs.
