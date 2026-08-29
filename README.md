# claude-output-styles

Claude Code output styles that cut wordiness and jargon.

Two styles are here. **Plain technical** is for everyday work. **Plain technical
(strict)** adds the mechanical writing limits of ASD-STE100 Simplified Technical English,
for documentation and for readers whose first language is not English.

## The problem these address

"Too wordy" is two different faults, and they need different rules.

**Discourse bloat** is restating the question before answering it, narrating what you are
about to do, a recap paragraph that repeats the body, hedging a verified result, and
three options when one was asked for.

**Sentence bloat** is long sentences, passive voice, noun stacks, and nouns built from
verbs ("performs an initialisation of" for "initialises").

Most complaints about verbose model output are the first kind. Sentence-level rules alone
will not fix it, which is why both styles lead with structure rules and only then limit
sentences.

## Try the built-in Concise style first

Claude Code ships a **Concise** output style from v2.1.237. It targets discourse bloat:
lead with the result, skip preamble and narration, keep responses short by default, and
answer in full when asked for detail.

It costs nothing to try and it may be all you need.

```
/config   ->  Output style  ->  Concise
/clear
```

Reach for this repo when you also want the sentence-level and vocabulary rules, or when
you want a style you can edit and version.

## Install

Clone anywhere, then copy the style you want to one of two places.

For every project you work on:

```bash
mkdir -p ~/.claude/output-styles
cp output-styles/plain-technical.md ~/.claude/output-styles/
```

For one repository, committed so your team shares it:

```bash
mkdir -p .claude/output-styles
cp output-styles/plain-technical.md .claude/output-styles/
```

Then select it and start a new session:

```
/config   ->  Output style  ->  Plain technical
/clear
```

The style is part of the system prompt, which Claude Code reads once at session start.
A change takes effect after `/clear` or in the next session.

To set it without the menu, put the style's name in a settings file:

```json
{
  "outputStyle": "Plain technical"
}
```

`~/.claude/settings.json` applies everywhere. `.claude/settings.local.json` applies to one
project and is the file the `/config` menu writes.

## What it costs

Close to nothing, and it should pay for itself.

An output style lives in the system prompt, so it caches. A cache read costs about 0.1x
the base input price, and an output token costs 5x an input token on Opus-tier models.

A 1,200-token style therefore costs about **24 output tokens per request**. If it removes
one sentence from the average reply, it has paid for itself. Over a 200-request session
the style costs a few pence and can save several times that in output tokens.

The intuition that a long system prompt is expensive comes from uncached input. Cached, it
is leverage on the tokens that actually cost money.

## Limits

**Styles do not reach subagents.** A subagent runs its own system prompt, so delegated
work comes back in the default voice. A fork is the exception, because it inherits the
parent's system prompt.

**Nothing verifies chat output.** A checker reads files. If you want the rules enforced,
run a checker over your documentation in CI and treat the style as a nudge everywhere
else.

**Jargon is sometimes compression.** "Idempotent" is one word standing in for a clause.
The rule that helps is *one term per concept*, not *simpler terms*. Replacing precise
terms with common ones makes text longer and vaguer.

**Do not let brevity eat evidence.** Both styles carry an explicit carve-out: error
output, stack traces, security findings, destructive-action confirmations, and anything
the reader must copy verbatim are quoted in full. A style without that carve-out will
truncate exactly the output where truncation hurts.

## On ASD-STE100

[ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/) is a controlled
language for technical documentation, owned by ASD, Brussels. Issue 9 was released on
15 January 2025. The official copy is free from their site. It has two parts: Part 1, the
writing rules, and Part 2, the dictionary of controlled vocabulary.

**The strict style implements Part 1 rules only.** Part 2 is copyright ASD and cannot be
redistributed, so no dictionary is included here and none is checked.

Do not describe output from this style as STE-conformant. It follows the mechanical rules.
Real conformance needs the dictionary and a checker.

This project is not affiliated with, endorsed by, or sponsored by ASD or the STE
Maintenance Group.

If you want an actual checker, two open-source projects exist:

- [sjtower/ste-plugin](https://github.com/sjtower/ste-plugin), a Claude Code plugin with a
  zero-dependency Node checker for CI. It ships no dictionary, by design.
- [sourdough-bread/asd-ste100-checker](https://github.com/sourdough-bread/asd-ste100-checker),
  a Python engine with CLI, MCP and LSP interfaces. Note that it commits dictionary data
  extracted from the copyrighted specification, which you may not want in a public
  repository.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
