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

## Measured effect

Measured on 2026-08-29, with Claude Code 2.1.251 on Claude Opus 5.

Twelve prompts against one repository at a fixed commit: three factual lookups, three
explanations, three judgement calls and three small tasks that use tools. Two runs per
prompt per arm, so 72 replies. The metric and the bar were fixed before the run: median
words per reply, and the strict style had to cut 15% against no style, and 5% more than
its sibling.

| Arm | Median words | Median sentence | Change |
|---|---|---|---|
| No style | 238 | 16 words | — |
| Plain technical | 182 | 12 words | -19% |
| Plain technical (strict) | 143 | 10 words | -27% |

The change column is the median of twelve per-prompt ratios, which is the honest
comparison: a lookup and an explanation differ in length far more than the arms do.
Both bars are cleared. The strict style cuts a further 20% against its sibling.

Correctness held. A separate grading session, which never saw which arm wrote which
reply, marked 18, 19 and 19 of 20 replies correct for the three arms. Judgement prompts
gained most under the strict style, at -45%. Lookups and small tasks gained least, at
about -18%.

**The gain is density, not a removed preamble.** The control arm already led with the
answer: zero preamble words at the median, and no reply in any arm restated the question.
Claude Code's own system prompt handles that much. What the styles remove is the second
explanation of a point already made, and the alternatives nobody asked for.

Read the numbers narrowly. One repository, one CLAUDE.md, 72 replies. Two of the twelve
prompts asked for a file edit and are excluded from the correctness counts, because the
harness reset the working tree between runs and the grader could not see the edits.

A rewrite of prose that already exists is a different task, and gains nothing. Rewriting
749 docstrings in one codebase under the strict style moved the word count by -0.7%.
A dense original costs words to unpack, and a per-sentence limit is content to split one
long sentence into two.

## Why two kinds of rule

"Too wordy" is two faults. Each needs a different rule.

**Discourse bloat** is a restated question, narration of the next step, a recap that
repeats the body, and three options when you asked for one.

**Sentence bloat** is long sentences, passive voice, noun stacks, and nouns built from
verbs.

Both styles lead with structure, because discourse bloat is the louder complaint. The
measurement above says the sentence rules earn their place too: the strict style differs
from its sibling mostly in those rules, and it cuts a further 20%.

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

Four rules in the strict style are not in Part 1. They are there because Part 1 alone
did not make a rewrite shorter.

The measurement is `gilesknap/thoth`: six leaf modules of 1,399 words for the rule
iteration, then 22 files of 9,425 words for the settled result, docstrings and comments,
rewritten against their own originals. The strict style as first written cut 5.5%. It
shortened every sentence, from a mean of 20.4 words to 15.0, and then wrote 60 sentences
where the original had 47. Every word the length rule squeezed out came back as sentence
count, because every limit in Part 1 is per sentence and nothing counts them.

Words are sentences times length. Three of the four rules below exist to stop the count
rising while the length falls.

| Added rule | Why it is there |
|---|---|
| Aim for 15 words a sentence. | Part 1 gives ceilings of 20 and 25 words and no target, so a rewrite writes up to the ceiling. Adding the target took the cut from 8.5% to 12.0%, at a mean of 13.2 words. |
| Recast a dash or semicolon join with a comma, a colon or a subordinate clause. Reach for a new sentence last. | Part 1 bans the join and does not say what replaces it. A full stop became the default, and two short sentences are usually longer than the one they replace. This took the sentence count back to 48 and the cut from 5.5% to 8.5%. |
| Do not add a sentence whose only job is to explain the sentence before it. | Part 1 is a sentence-level standard, so nothing in it forbids the elaborating sentence. `plain-technical.md` already carried this rule and the strict style had lost it. |
| Do not finish with more sentences than you started with. Shorten a long sentence by removing words, not by cutting it in two. | The recast rule and the 15-word target pull against each other: hitting 15 words makes the full stop the easy way out. Without this rule every batch still came out about 25% more sentences than it started with, and gave the length win straight back. |

Writing below a ceiling is still conformant, so the 15-word target adds no conflict.

The recast rule does pull against Part 1's "one meaning per sentence", because a
subordinate clause keeps two things in one sentence. This style reads that rule as
forbidding a second *idea*, not a qualifier. That is a judgement call, and it is the one
place the strict style takes a liberty with the standard.

### What the rules do not buy

Across the 22 files the four rules cut 6.7%, holding every docstring, every `Args:` entry
and 157 of 160 Sphinx cross-reference roles. The same files rewritten in a free personal
register cut 17.5%, and the difference is mostly not writing quality. That rewrite keeps
53 of the 160 roles, and it reaches its figure partly by deleting things the code does not
carry: a parsing regex and its literal example, a table's DDL, three constant names, two
of four named call sites.

So the reduction is uneven, and it is worth knowing where it lives. Prose that repeats
itself compresses hard: the six leaf modules came in at 17.0%, past the free rewrite's
16.3% on the same files while keeping all 28 of their roles against its 16. Dense
reference prose that states each fact once has almost nothing to give, and holding
"Never drop these" puts its honest floor near 5%. A style cannot make a docstring shorter
than its content.

Three limits on the measurement. It is one codebase, docstrings and comments only, so the
percentages will move on other prose. The comparison rewrite is one person's register,
not a control. And two further rules were tried and dropped: capping a paragraph at one
or two sentences changed nothing, because the observed mean was already 1.9, and
re-wrapping paragraphs to fill the column budget gained one line in 169.

This project has no affiliation with ASD or the STE Maintenance Group.

For a real checker, see [sjtower/ste-plugin](https://github.com/sjtower/ste-plugin), which
ships no dictionary by design, or
[sourdough-bread/asd-ste100-checker](https://github.com/sourdough-bread/asd-ste100-checker),
which commits dictionary data taken from the specification.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
