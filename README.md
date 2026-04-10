# untrack-ignored

Finds files that are tracked by git but match `.gitignore`, and untracks them.

## Setup

Add the containing folder of this repo to your `PATH` (User environment variables), then call from anywhere inside a git repository.

## Usage

```
untrack-ignored --print      List all tracked files that should be ignored
untrack-ignored --rm         Untrack them (files stay on disk)
untrack-ignored --restore    Undo the last --rm
```

## How it works

- `--print` — runs `git ls-files | git check-ignore --stdin` to find tracked files that match `.gitignore`
- `--rm` — runs `git rm --cached` on each one and saves the list to `.git/untrack-ignored.removed`
- `--restore` — reads that saved list and runs `git restore --staged` on each file

## Notes

- Must be run from within a git repository (any subfolder works)
- `--restore` only works before committing — once you commit the removal, the state file is stale
- The state file lives in `.git/` so it is never tracked by git
