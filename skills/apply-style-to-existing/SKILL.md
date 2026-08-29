---
name: apply-style-to-existing
description: Rewrite the docstrings and comments in an existing codebase to match the output style you have active, without changing behaviour and without losing facts. Use when asked to "apply my style to this repo", "rewrite the docstrings in your current style", or to clean up verbose comments across a project.
---

# Apply your style to an existing codebase

An output style shapes what you write from now on. It does nothing to what is already
there. This skill covers the backfill: read every docstring and comment, rewrite it in
the style you have active, and prove you broke nothing.

The style supplies the voice. This skill supplies the safety. Do not restate the style's
rules here, and do not override them.

## Before you start

**Commit or stash first.** Every check here compares against a git ref.

**Do the work in the main conversation.** An output style does not reach a subagent, so
a delegated batch comes back in the default voice with no fact guards. If you must fan
out, put the style's rules in `CLAUDE.md`, which subagents do load.

**Confirm which style is active.** Ask the user if it is not obvious. A rewrite under
the wrong style is a wasted pass over every file.

**Settle the docstring mood.** Most codebases open in the third person, as in `"""Farms
a single media download."""`. A style that mandates imperatives turns that into `"""Farm
a single media download."""`, which is a convention change, not a voice change. Agree it
with the user before the first file, not after the eightieth.

## What survives a rewrite, always

Prose can be tightened freely. These carry what no paraphrase reproduces, so they survive
verbatim.

**A symbol is not prose.** A formula, a regex, a wire-format fragment, an environment
variable, a JSON or protocol field name, and the valid values of a stringly-typed
argument. One rewrite turned `Σ 1 / (RRF_K + rank)` into "the sum of one over the constant
plus its rank", which is slower to read and silently drops the 0-based rank. Compress the
sentence around the token, never the token.

**An exception type is a fact.** "Returns the API key, or raises `ConfigError` if unset"
must not become "Returns the API key". Raising is the only interesting thing a `require_`
method does. Keep the type in the sentence, or give the function a `Raises:` block.

**A list is not prose.** An enumeration of a fixed set that the reader will scan or count
keeps its bullets. Cut the words inside each item instead.

**A parameter the prose explained must land in `Args:`.** Deleting a whole block is the
failure everyone expects, so nobody commits it. The failure that gets through is a
tightened narrative that stopped naming six of a method's ten parameters, with no block to
have promoted them into.

**Leave model-facing text alone.** A tool description, a `.tool`-decorated docstring, or
any prompt string is read by a model at run time, not by a person. `degoogle.py` refuses
to touch them. You should too.

## Three mechanical traps

**Escapes.** A docstring is a normal string, so a regex written into one turns `\b` into a
backspace byte, `\t` into a tab and `\n` into a newline. Double the backslash. One rewrite
shipped two literal 0x08 bytes into a published API page, invisible in the diff, in review
and in `git show`. `keptfacts.py` checks for the byte directly.

**The summary line must fit the column limit including its indent and its opening quotes.**
No script wraps it for you. Keep a method summary under about 70 characters.

**Wrap a list for the indent it will sit at.** Text wrapped for a module docstring
overflows once nested inside a method.

## The workflow

Ten files at a time. The checks are cheap; a hundred-file pass that fails at the end is
not.

1. Read the whole file before you change any of it.
2. Rewrite. Use `setdoc.py` to replace a docstring by AST position, so an edit cannot land
   on the wrong copy of a repeated line.
3. Run `codesame.py <ref> <files>`. It must exit 0.
4. Run `keptfacts.py <ref> <files>` and **read the output**. Do not aim for zero: a
   rewrite that dropped nothing has cut nothing. Put back anything the code below does not
   already spell out.
5. Run `longblocks.py --limit N` if your style caps paragraph length, with N from that
   style. Skip it if the style sets no cap.
6. Run `degoogle.py` only if the project uses Google-style sections.
7. Run the test suite.

## The scripts

They fall into two groups, and the difference matters. **The verifiers hold whatever style
you use.** The formatters carry opinions, so check that each one matches your project
before you run it.

### Verifiers: run these always

| Script | What it proves |
|---|---|
| `codesame.py <ref> <path>...` | Strips docstrings from both sides and compares ASTs, so "nothing behavioural changed" is proved rather than asserted. No style opinion whatsoever. Run it on every file you touch. |
| `keptfacts.py <ref> [path]...` | Pairs each docstring with its old self by qualname and lists the facts that went: a parameter, a symbol, a constant, an exception type, an issue reference, a Sphinx role. Also flags the escape byte. No style wants these dropped. |
| `setdoc.py <path> <qualname>` | Replaces one docstring with stdin, addressed by AST position, so an edit cannot land on the wrong copy of a repeated line. A mechanism, not a rule. |

A non-zero exit from `keptfacts.py` means **look**, not **fail**. A rewrite that dropped
nothing has cut nothing.

Two of its checks assume comments open with a capital letter. Ignore those rows if your
style says otherwise.

### Formatters: check they suit your project first

| Script | What it assumes |
|---|---|
| `longblocks.py [--limit N] [path]...` | That your style caps paragraph length, and by default that the cap is 3 sentences. **Set `--limit` from your own style.** The strict style in this repo caps paragraphs at 6, so run `--limit 6`. Skip the script entirely if your style sets no cap. |
| `degoogle.py [path]...` | Google-style sections and an 88-column limit. It matches each function's sections to the git ref's own layout, so it preserves a contract rather than imposing one. It has nothing to offer a NumPy or reST codebase, where it will find no sections and only re-wrap. It refuses to touch a `.tool` docstring. |

Neither formatter is required. The verifiers are.

All five are Python 3, standard library only, and none needs the project installed.

## Judging the result

Count the lines, not only the words. A rewrite that cuts words but grows the diff has
moved the verbosity rather than removed it.

Then read three files as a reader, not as an author. Every mechanical check can pass on
prose that is worse.
