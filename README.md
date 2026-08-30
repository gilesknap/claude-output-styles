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
| Plain technical (strict) | This repo | The mechanical limits of ASD-STE100: 20-word procedural sentences, imperatives, no -ing forms, no contractions. Plus [four additions](#what-the-strict-style-adds). |

Option 4 in the script removes the setting and returns you to stock Claude Code.

## Measured effect

Measured on 2026-08-30, with Claude Code 2.1.251 on Claude Opus 5.

Twelve prompts against one repository at a fixed commit: three factual lookups, three
explanations, three judgement calls and three small tasks that use tools. Two runs per
prompt per arm, so 96 replies. The metric and the bar were fixed before the run: median
words per reply, and the strict style had to cut 15% against no style, and 5% more than
its sibling.

| Arm | Median words | Median sentence | vs no style | vs Concise |
|---|---|---|---|---|
| No style | 238 | 16 words | — | +22% |
| Concise (built in) | 168 | 15 words | -18% | — |
| Plain technical | 182 | 12 words | -19% | +6% |
| Plain technical (strict) | 143 | 10 words | -27% | **-17%** |

Each change column is the median of twelve per-prompt ratios, which is the honest
comparison: a lookup and an explanation differ in length far more than the arms do.

**Try Concise first, and mean it.** The built-in style does most of the work for nothing.
Plain technical matched it and did not beat it. Only the strict style pulled clear, by a
further 17%, and that is the number to weigh against installing anything.

Correctness held in every arm. A separate grading session, which never saw which arm
wrote which reply, marked 18, 18, 19 and 19 of 20 replies correct, in table order.
Judgement prompts gained most under the strict style, at -45%. Lookups and small tasks
gained least, at about -18%.

**The gain is density, not a removed preamble.** The no-style arm already led with the
answer: zero preamble words at the median, and no reply in any arm restated the question.
Claude Code's own system prompt handles that much. What a style removes is the second
explanation of a point already made, and the alternatives nobody asked for.

Read the numbers narrowly. One repository, one CLAUDE.md, 96 replies, and a style shapes
chat rather than files. Two of the twelve prompts asked for a file edit and are excluded
from the correctness counts, because the harness reset the working tree between runs and
the grader could not see the edits.

## Why two kinds of rule

"Too wordy" is two faults. Each needs a different rule.

**Discourse bloat** is a restated question, narration of the next step, a recap that
repeats the body, and three options when you asked for one.

**Sentence bloat** is long sentences, passive voice, noun stacks, and nouns built from
verbs.

Both styles lead with structure, because discourse bloat is the louder complaint. But
Concise already covers the structure rules, and the measurement above shows that a style
which stops there buys nothing over it. The sentence rules are what the strict style adds
and what its further 17% comes from.

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

**The strict style implements Part 1 writing rules, plus four of its own.** Part 2 is
copyright ASD, so this repo ships no dictionary and checks no vocabulary. Do not call the
output STE-conformant.

### What the strict style adds

Four rules in the strict style are not in Part 1. Part 1 is a sentence-level standard,
and every limit in it is per sentence. Nothing in it counts sentences. A style that only
caps sentence length therefore buys its shorter sentences by writing more of them, and
words are sentences times length.

| Added rule | What it does |
|---|---|
| Aim for 15 words a sentence. | Part 1 gives ceilings of 20 and 25 words and no target. A ceiling on its own is a licence to write up to it. |
| Recast a dash or semicolon join with a comma, a colon or a subordinate clause. Reach for a new sentence last. | Part 1 bans the join and does not say what replaces it. Left alone, a full stop becomes the default, and two short sentences are usually longer than the one they replace. |
| Do not add a sentence whose only job is to explain the sentence before it. | Part 1 does not forbid the elaborating sentence. `plain-technical.md` already carried this rule and the strict style had lost it. |
| Do not finish with more sentences than you started with. Shorten a long sentence by removing words, not by cutting it in two. | The recast rule and the 15-word target pull against each other: hitting 15 words makes the full stop the easy way out. |

Writing below a ceiling is still conformant, so the 15-word target adds no conflict.

The recast rule does pull against Part 1's "one meaning per sentence", because a
subordinate clause keeps two things in one sentence. This style reads that rule as
forbidding a second *idea*, not a qualifier. That is a judgement call, and it is the one
place the strict style takes a liberty with the standard.

These four rules are most of what separates the strict style from its sibling, and the
measurement above is what they buy: a further 17% against Concise, where the sibling
buys nothing.

This project has no affiliation with ASD or the STE Maintenance Group.

For a real checker, see [sjtower/ste-plugin](https://github.com/sjtower/ste-plugin), which
ships no dictionary by design, or
[sourdough-bread/asd-ste100-checker](https://github.com/sourdough-bread/asd-ste100-checker),
which commits dictionary data taken from the specification.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
