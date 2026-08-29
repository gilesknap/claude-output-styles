#!/usr/bin/env python3
"""Report how much prose a rewrite added or removed, per file and in total.

    sizecheck.py <ref> <path>... [--tolerance PCT]

Counts the words in every docstring and every comment, on both sides, and prints
one row per file plus a total. Exits non-zero when the total grew by more than the
tolerance, 2% by default.

The tolerance is deliberate. A hard zero pushes you to buy words back by cutting a
fact or blurring a sentence, which is worse than the growth. A batch a couple of
percent over is noise, usually terse originals that were already close to the
style. A batch 10% over is a reading of the style, and that is what this catches.

It has no opinion about style. It measures one thing a style cannot measure about
itself: whether the whole batch ended up longer than it started.
"""

from __future__ import annotations

import ast
import io
import subprocess
import sys
import tokenize
from pathlib import Path

DOC_NODES = (ast.Module, ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)


def docstring_words(source: str) -> int:
    """Total words across every module, class and function docstring."""
    try:
        tree = ast.parse(source)
    except SyntaxError:
        return 0
    total = 0
    for node in ast.walk(tree):
        if isinstance(node, DOC_NODES):
            text = ast.get_docstring(node)
            if text:
                total += len(text.split())
    return total


def comment_words(source: str) -> int:
    """Total words across every ``#`` comment, minus the marker itself."""
    total = 0
    try:
        tokens = tokenize.generate_tokens(io.StringIO(source).readline)
        for token in tokens:
            if token.type == tokenize.COMMENT:
                total += len(token.string.lstrip("#").split())
    except (tokenize.TokenError, IndentationError, SyntaxError):
        return total
    return total


def measure(source: str) -> tuple[int, int]:
    """Return ``(docstring words, comment words)`` for one file's source."""
    return docstring_words(source), comment_words(source)


def at_ref(ref: str, path: str) -> str:
    """Return the file's contents at ``ref``, or empty when it did not exist."""
    result = subprocess.run(
        ["git", "show", f"{ref}:{path}"],
        capture_output=True,
        text=True,
    )
    return result.stdout if result.returncode == 0 else ""


def main(argv: list[str]) -> int:
    args = argv[1:]
    tolerance = 2.0
    if "--tolerance" in args:
        index = args.index("--tolerance")
        try:
            tolerance = float(args[index + 1])
        except (IndexError, ValueError):
            print("--tolerance needs a number, e.g. --tolerance 2", file=sys.stderr)
            return 2
        del args[index : index + 2]
    if len(args) < 2:
        print((__doc__ or "").strip(), file=sys.stderr)
        return 2
    ref, paths = args[0], args[1:]

    old_doc = new_doc = old_com = new_com = 0
    rows: list[tuple[int, int, int, str]] = []

    for path in paths:
        before = measure(at_ref(ref, path))
        after = measure(Path(path).read_text(encoding="utf-8"))
        old_doc += before[0]
        old_com += before[1]
        new_doc += after[0]
        new_com += after[1]
        was = before[0] + before[1]
        now = after[0] + after[1]
        rows.append((now - was, was, now, path))

    for delta, was, now, path in sorted(rows, reverse=True):
        flag = "  <-- GREW" if delta > 0 else ""
        print(f"{delta:+6d}  {was:6d} -> {now:6d}  {path}{flag}")

    was_total = old_doc + old_com
    now_total = new_doc + new_com
    pct = 100 * (now_total - was_total) / was_total if was_total else 0.0
    print(
        f"\ndocstrings {old_doc} -> {new_doc}   comments {old_com} -> {new_com}\n"
        f"TOTAL {now_total - was_total:+d} words  "
        f"{was_total} -> {now_total}  ({pct:+.1f}%)"
    )
    if pct > tolerance:
        print(
            f"\nThe rewrite added {pct:.1f}%, over the {tolerance:.0f}% tolerance.\n"
            "Re-read how you are applying the style. Do not buy the words back by "
            "cutting a fact or blurring a sentence."
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
