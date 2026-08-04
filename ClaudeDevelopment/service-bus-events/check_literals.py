"""Verify every T-SQL string literal in a script terminates where intended.

Inside a T-SQL literal, '' is an escaped quote and a lone ' ends the literal.
A script whose literals do not all close has a quote-doubling bug.

Usage: python check_literals.py <file.sql> [<file.sql> ...]
"""
import io
import sys


def scan(fname):
    """Single left-to-right scan over the raw source.

    Tracks literal state and comment state together so a '--' or '/*' that
    appears *inside* an already-open string literal is never mistaken for a
    real comment marker (T-SQL string contents have no comment syntax), and
    so a quote inside a real comment is never mistaken for the start of a
    literal. Block comments (/* ... */) nest in T-SQL, so nesting depth is
    tracked; line comments (--) run to the next newline.
    """
    src = io.open(fname, encoding="utf-8").read()
    n = len(src)
    i = 0
    literals = 0
    closed = True
    block_depth = 0

    while i < n:
        if block_depth > 0:
            if src.startswith("/*", i):
                block_depth += 1
                i += 2
            elif src.startswith("*/", i):
                block_depth -= 1
                i += 2
            else:
                i += 1
            continue

        c = src[i]

        if src.startswith("--", i):
            nl = src.find("\n", i)
            i = n if nl == -1 else nl
            continue

        if src.startswith("/*", i):
            block_depth = 1
            i += 2
            continue

        if c == "'":
            literals += 1
            i += 1
            terminated = False
            while i < n:
                if src[i] == "'":
                    if i + 1 < n and src[i + 1] == "'":
                        i += 2
                        continue
                    i += 1
                    terminated = True
                    break
                i += 1
            if not terminated:
                closed = False
            continue

        i += 1

    return literals, closed


def main():
    failed = False
    for fname in sys.argv[1:]:
        literals, closed = scan(fname)
        status = "OK" if closed else "UNTERMINATED LITERAL"
        print(f"{fname:52} literals={literals:4}  {status}")
        if not closed:
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
