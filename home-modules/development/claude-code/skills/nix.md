---
name: nix
description: 'Nix derivation debugging, NixOS test debugging, and Nix code style guidelines. Always use when working with Nix derivations, NixOS configurations, NixOS module options, or writing Nix code. TRIGGER when: working in a NixOS or home-manager repo; about to search the filesystem for Nix store paths or derivation outputs; writing or debugging any .nix file.'
---

> **Important:** Flake evaluation requires a clean git tree. Run `git add` on new/modified files before `nix flake check` to avoid path resolution errors.

## Nix Code Style

- Always run `nix fmt` before committing
- **Never** use `with lib;` or `rec`
- Use `let inherit (lib) fn1 fn2; in` instead of `lib.fn1`, `lib.fn2`
- Use `let inherit (pkgs) pkg1 pkg2; in` instead of `pkgs.pkg1`, `pkgs.pkg2`
- For nested sets (e.g. `lib.types`), inherit from the nested set: `inherit (lib.types) str int`
- Merge all inherits into a single `let...in` block alongside any other `let` bindings
- Use `lib.pipe` to reduce complex nested statements where it makes sense:
  ```nix
  lib.pipe 2 [
    (x: x + 2)  # 2 + 2 = 4
    (x: x * 2)  # 4 * 2 = 8
  ]
  ```

## Debugging Nix Derivations

When debugging Nix derivations, **never** use random `find` or `grep` commands in `/nix/store` — the store contains many unrelated builds and you will get wrong or outdated results.

**Evaluate the exact output path:**

```bash
nix eval --raw .#packages.x86_64-linux.myPackage.out
```

**Build and get the store path (no result symlink):**

```bash
nix build --no-link --print-out-paths .#packages.x86_64-linux.myPackage
# prints the store path; inspect it directly:
ls $(nix build --no-link --print-out-paths .#packages.x86_64-linux.myPackage)/
```

**Check the build log:**

```bash
nix log .#packages.x86_64-linux.myPackage
```

**Keep failed builds for inspection:**

```bash
nix build --keep-failed .#packages.x86_64-linux.myPackage
ls /tmp/nix-build-*-myPackage-*/
```

## Debugging NixOS Tests

NixOS tests use QEMU virtual machines controlled by a Python test driver.

### Step 1 — Analyze the full log in a subagent

Test logs are verbose. Delegate analysis to a subagent to preserve context window.

```bash
nix build .#checks.x86_64-linux.<test-name> 2>&1 | tee /tmp/test-build.log || true
nix log .#checks.x86_64-linux.<test-name> > /tmp/test.log 2>&1 || true
```

Spawn a subagent to read and summarize `/tmp/test.log`. Only proceed to interactive debugging if the summary is insufficient.

### Step 2 — Interactive driver

The NixOS test framework provides a Python REPL (`nixos-test-driver`) that controls VMs.

**Build the interactive driver:**

```bash
DRIVER=$(nix build --no-link --print-out-paths .#checks.x86_64-linux.<test-name>.driverInteractive)
```

**Interact via heredoc** (Claude's Bash tool does not support interactive REPLs — use piped stdin):

```bash
$DRIVER/bin/nixos-test-driver << 'EOF'
start_all()
machine.wait_for_unit("multi-user.target")
print(machine.execute("systemctl status <service>"))
print(machine.execute("journalctl -u <service> --no-pager -n 50"))
print(machine.execute("cat /etc/<config-file>"))
EOF
```

> `machine.shell_interact()` requires an interactive terminal and cannot be used with Claude. Use `machine.execute()` instead.

**Common driver commands:**

```python
start_all()                            # Start all VMs
machine.wait_for_unit("svc.service")   # Wait for systemd unit
machine.execute("cmd")                 # Run command → (exit_code, stdout)
machine.succeed("cmd")                 # Run command, raises on non-zero exit
machine.fail("cmd")                    # Run command, raises if exit is zero
machine.wait_for_open_port(80)         # Wait for TCP port
machine.wait_for_file("/path")         # Wait for file to appear
machine.copy_from_host("src", "dst")   # Copy file into VM
```

Machine naming: single-machine tests use `machine`; multi-machine tests use names from the `nodes` attribute.
