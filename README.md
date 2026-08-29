# claude-output-styles

Claude Code output styles that cut wordiness and jargon.

This README follows the strict style, as a sample of what it does to prose.

## Quickstart

```bash
git clone https://github.com/gilesknap/claude-output-styles.git
cd claude-output-styles
./examples/install.sh
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
| Plain technical (strict) | This repo | The mechanical limits of ASD-STE100: 20-word procedural sentences, imperatives, no -ing forms, no contractions. |

Option 4 in the script removes the setting and returns you to stock Claude Code.

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

## On ASD-STE100

[ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/) is a controlled
language for technical documentation. ASD of Brussels owns it. Issue 9 dates from
15 January 2025. The official copy is free from their site.

The specification has two parts: Part 1, the writing rules, and Part 2, the dictionary.

**The strict style implements Part 1 rules only.** Part 2 is copyright ASD, so this repo
ships no dictionary and checks no vocabulary. Do not call the output STE-conformant.

This project has no affiliation with ASD or the STE Maintenance Group.

For a real checker, see [sjtower/ste-plugin](https://github.com/sjtower/ste-plugin), which
ships no dictionary by design, or
[sourdough-bread/asd-ste100-checker](https://github.com/sourdough-bread/asd-ste100-checker),
which commits dictionary data taken from the specification.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
