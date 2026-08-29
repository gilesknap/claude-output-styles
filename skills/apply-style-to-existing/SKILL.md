---
name: apply-style-to-existing
description: Rewrite the docstrings and comments in an existing codebase to match the output style you have active, without changing behaviour. Use when asked to "apply my style to this repo", "rewrite the docstrings in your current style", or to clean up verbose comments across a project.
---

# Apply your style to an existing codebase

An output style shapes what you write from now on. It does nothing to what is already
there. This skill covers the backfill: read every docstring and comment, rewrite it in the
style you have active, and prove you broke nothing.

**The style supplies the voice. This skill supplies only what a style cannot.** Do not
restate the style's rules here, do not override them, and do not add rules of your own
about length, mood or layout. If the style does not ask for it, it is not a requirement.

Trust the style for the writing. The same trust you extend to a new docstring applies to a
rewritten one.

## What a rewrite risks that new writing does not

Two things, and only two.

**It can change code.** An edit to a docstring can land on the wrong line, or a triple
quote can swallow a statement. `codesame.py` settles this, and running it is not
optional.

**It can lose a fact the code does not carry.** A new docstring takes its facts from the
code in front of you, so there is nothing to lose. An old one may hold what the code does
not: why a constant is 60, an issue reference, a wire-format quirk, the reason a
workaround exists. Rewrite over that and it leaves the repository.

Everything else about the rewrite is the style's business.

## Before you start

**Commit or stash first.** Every check compares against a git ref.

**Work in the main conversation.** An output style does not reach a subagent, so a
delegated batch comes back in the default voice. If you must fan out, put the style's rules
in `CLAUDE.md`, which subagents do load.

**Confirm which style is active.** A rewrite under the wrong style wastes a pass over every
file.

**Settle the docstring mood once.** Most codebases open in the third person, as in
`"""Farms a single media download."""`. A style that mandates imperatives turns that into
`"""Farm a single media download."""`, which is a convention change rather than a voice
change. Agree it before the first file.

**Leave model-facing text alone.** A tool description, a `.tool`-decorated docstring, or a
prompt string is read by a model at run time, not by a person. Rewriting one changes
behaviour.

## One trap worth knowing

A docstring is a normal string, so a regex written into one turns `\b` into a backspace
byte, `\t` into a tab and `\n` into a newline. Double the backslash.

One rewrite shipped two literal 0x08 bytes into a published API page. They were invisible
in the diff, in review and in `git show`. `keptfacts.py` checks for the byte directly, and
ruff catches it as PLE2510 only where `PL` is selected, which it often is not.

## The workflow

Ten files at a time. A hundred-file pass that fails at the end is worse than ten that pass.

1. Read the whole file before you change any of it.
2. Rewrite in the active style.
3. Run `codesame.py <ref> <files>`. It must exit 0.
4. Run the test suite.

That is the whole required loop.

## The scripts

Three, all Python 3 and standard library only. None needs the project installed.

| Script | Status | What it does |
|---|---|---|
| `codesame.py <ref> <path>...` | **Required** | Strips docstrings from both sides and compares ASTs, so a docs-only rewrite is proved rather than asserted. Exits non-zero on any code change. No style opinion at all. |
| `keptfacts.py <ref> [path]...` | Optional | Pairs each docstring with its old self by qualname and lists facts the rewrite dropped: a parameter, a symbol, a constant, an exception type, an issue reference, a Sphinx role. Also flags the escape byte. |
| `setdoc.py <path> <qualname>` | Optional | Replaces one docstring with stdin, addressed by AST position, so an edit cannot land on the wrong copy of a repeated line. Takes `<module>` for the module docstring. A safer edit, not a check. |

`keptfacts.py` is a filtered diff, not a verdict. Its exit code gates nothing, and a
non-zero exit means look rather than fail. A rewrite that dropped nothing has cut nothing,
so read the rows and put back only what the surrounding code does not already say.

Reach for it after a large pass, not after every batch. Two of its checks assume comments
open with a capital letter; ignore those rows if your style says otherwise.

## Formatting

Do not run a docstring formatter as part of this skill. The style handles layout.

If the project already runs one, such as `docformatter` in pre-commit, that is the
project's decision and it applies to new writing too. Note that `docformatter` capitalises
a summary's first word, adds a terminal full stop, and defaults to 72 and 79 columns rather
than 88.

## Judging the result

Count the lines, not only the words. A rewrite that cuts words but grows the diff has moved
the verbosity rather than removed it.

Then read three files as a reader. Every mechanical check can pass on prose that is worse.
