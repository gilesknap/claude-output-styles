# claude-output-styles

Claude Code output styles that cut wordiness and jargon.

This README follows the strict style, as a sample of what it does to prose.

## Quickstart

```bash
git clone https://github.com/gilesknap/claude-output-styles.git
cd claude-output-styles
./install.sh
```

The script asks which style you want and where to apply it. Press Enter twice for the
built-in Concise style, everywhere.

Then run `/clear`, or start a new session. A style loads at session start only.

The script needs `jq`. It backs up your settings file and merges one field. It never
replaces settings you already have.

To set the field yourself instead, copy a fragment from [`examples/`](examples/).

## The styles

| Style | Source | What it adds |
|---|---|---|
| Concise | Built into Claude Code | Leads with the result. Skips preamble and narration. Try this first. |
| Plain technical | This repo | Active voice, shorter sentences, one term per concept, a filler cut-list. |
| Plain technical (strict) | This repo | The mechanical limits of ASD-STE100: 20-word procedural sentences, imperatives, no -ing forms, no contractions. Plus [three additions](#what-the-strict-style-adds). |

Option 4 in the script removes the setting and returns you to stock Claude Code.

## Apply a style to an existing codebase

A style shapes what Claude writes from now on. It does nothing to code you already have.

The `apply-style-to-existing` skill covers the backfill. It reads every docstring and
comment and rewrites each one in whichever style you have active.

```bash
./install.sh skill
```

That installs the skill, changes no style, and touches no settings file. Menu option 5 does
the same.

### How to ask for it

The skill loads on demand. Name it, and say what you want done.

```text
Rewrite the docstrings and comments in src/thoth to match my current output style.
Use the skill, and work on the restyle-docstrings branch.
```

Three clauses, each doing one job.

- **`src/thoth`** sets the scope. Name a directory rather than a whole repository. The
  skill rewrites ten files at a time.
- **"my current output style"** sets the voice. The skill adds no writing rules of its own,
  so the active style decides every question about the prose.
- **"the restyle-docstrings branch"** gives the checks a clean base. Every check compares
  against a git ref, so commit or stash before you start.

The skill asks you one question before the first file: the docstring mood. Most codebases
open in the third person, as in `"""Farms a single media download."""`. A style that
mandates imperatives rewrites that to `"""Farm a single media download."""`, in every file.

That is a convention change rather than a voice change, so the skill puts it to you. Add
"use the style's defaults for mood" to answer in advance.

The skill adds no writing rules. It trusts the style, exactly as you trust it for new code.
It carries the things a style cannot: what a rewrite risks, and a check for each risk.

A rewrite risks three things that new writing does not.

It can change code, and `codesame.py` settles that by comparing ASTs with docstrings
stripped. It can lose a fact the code does not carry, such as why a constant holds its
value, and `keptfacts.py` lists those. It can end up longer than what it replaced, and
`sizecheck.py` counts the words on both sides.

That third one is the surprise. New writing under a plain style is short because there is
no dense original in front of you. A rewrite has one, and unpacking a dash-jointed
sentence into two clean ones costs words every time. A style's limits are per sentence,
so splitting a 40-word sentence into two 20-word ones passes every rule and still grows
the file. Nothing inside a style notices.

All three run on every batch. None has an opinion about style, so none asks you anything.

## Why two kinds of rule

"Too wordy" is two faults. Each needs a different rule.

**Discourse bloat** is a restated question, narration of the next step, a recap that
repeats the body, and three options when you asked for one.

**Sentence bloat** is long sentences, passive voice, noun stacks, and nouns built from
verbs.

Most complaints are the first kind. Sentence limits alone do not fix it, so both styles
lead with structure.

## What it costs

A style sits in the system prompt, so it caches. A cache read costs about 0.1x base input.
An output token costs 5x an input token.

A 1,200-token style therefore costs about 24 output tokens per request. One sentence
removed from the average reply pays for it.

## Gotchas

Each of these makes a style do nothing. None of them raise an error.

- **`keep-coding-instructions` defaults to `false`.** A custom style without it drops
  Claude Code's engineering instructions. You get terser output and a worse engineer.
  Both styles here set it `true`. Set it in any style you write.
- **The style name is the frontmatter `name:`, not the file name.** Use
  `"Plain technical"`, never `"plain-technical"`.
- **A change mid-session does nothing.** Claude Code reads the style once, at session
  start. Run `/clear`.
- **A plugin can override your choice.** A plugin style with `force-for-plugin: true`
  wins over your setting.
- **`/config` writes to `.claude/settings.local.json`.** That file outranks
  `~/.claude/settings.json`, so a choice in one project can override your global one.
- **`--safe-mode` turns styles off**, with CLAUDE.md, skills, plugins and hooks.
- **CLAUDE.md can fight the style.** It arrives after the system prompt. An instruction
  such as "explain your reasoning at each step" pulls the other way.

## Subagents keep their own voice

A style shapes the main conversation. A subagent runs its own system prompt, so the style
never reaches it. Expect delegated work to sound different.

A CLAUDE.md rule reaches most subagents and narrows the gap. It does not close the gap:
CLAUDE.md is a user message rather than a system prompt, and the built-in Explore and Plan
agents skip it. Treat it as a nudge.

[`examples/CLAUDE.md-snippet.md`](examples/CLAUDE.md-snippet.md) holds a short excerpt for
that purpose. Keep any such excerpt short, because every subagent loads it.

The reliable place for a subagent's voice is the agent definition itself. Its markdown
body **is** its system prompt.

## What a style cannot do

No checker reads chat output. Enforce rules on documentation in CI. Treat a style as a
nudge everywhere else.

Jargon is sometimes compression. "Idempotent" is one word for a whole clause. The rule
that helps is one term per concept, not simpler terms.

Brevity must not remove evidence. Both styles quote error output, stack traces, security
findings and destructive-action effects in full.

Brevity must not remove a contract either. Both styles forbid the removal of a docstring,
an `Args:`, `Returns:` or `Raises:` section, or documentation coverage, to meet a length
rule.

## On ASD-STE100

[ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/) is a controlled
language for technical documentation. ASD of Brussels owns it. Issue 9 dates from
15 January 2025. The official copy is free from their site.

The specification has two parts: Part 1, the writing rules, and Part 2, the dictionary.

**The strict style implements Part 1 writing rules, plus three of its own.** Part 2 is
copyright ASD, so this repo ships no dictionary and checks no vocabulary. Do not call the
output STE-conformant.

### What the strict style adds

Three rules in the strict style are not in Part 1. They are there because Part 1 alone
did not make a rewrite shorter.

The measurement is six files of `gilesknap/thoth`, 1,399 words of docstrings and
comments, rewritten against their own originals. The strict style as first written cut
5.5%. It shortened every sentence, from a mean of 20.4 words to 15.0, and then wrote 60
sentences where the original had 47. Every word the length rule squeezed out came back
as sentence count, because every limit in Part 1 is per sentence and nothing counts them.

| Added rule | Why it is there |
|---|---|
| Aim for 15 words a sentence. | Part 1 gives ceilings of 20 and 25 words and no target, so a rewrite writes up to the ceiling. Adding the target took the cut from 8.5% to 12.0%, at a mean of 13.2 words. |
| Recast a dash or semicolon join with a comma, a colon or a subordinate clause. Reach for a new sentence last. | Part 1 bans the join and does not say what replaces it. A full stop became the default, and two short sentences are usually longer than the one they replace. This took the sentence count back to 48 and the cut from 5.5% to 8.5%. |
| Do not add a sentence whose only job is to explain the sentence before it. | Part 1 is a sentence-level standard, so nothing in it forbids the elaborating sentence. `plain-technical.md` already carried this rule and the strict style had lost it. |

Writing below a ceiling is still conformant, so the 15-word target adds no conflict.

The recast rule does pull against Part 1's "one meaning per sentence", because a
subordinate clause keeps two things in one sentence. This style reads that rule as
forbidding a second *idea*, not a qualifier. That is a judgement call, and it is the one
place the strict style takes a liberty with the standard.

Two limits on the measurement. It is one codebase, six files, docstrings and comments
only, so the percentages will move on other prose. And a fourth rule was tried and
dropped: capping a paragraph at one or two sentences changed nothing, because the
observed mean was already 1.9.

This project has no affiliation with ASD or the STE Maintenance Group.

For a real checker, see [sjtower/ste-plugin](https://github.com/sjtower/ste-plugin), which
ships no dictionary by design, or
[sourdough-bread/asd-ste100-checker](https://github.com/sourdough-bread/asd-ste100-checker),
which commits dictionary data taken from the specification.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
