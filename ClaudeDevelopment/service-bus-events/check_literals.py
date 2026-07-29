"""Verify every T-SQL string literal in a script terminates where intended.

Inside a T-SQL literal, '' is an escaped quote and a lone ' ends the literal.
A script whose literals do not all close has a quote-doubling bug.

Usage: python check_literals.py <file.sql> [<file.sql> ...]
"""
import io
import sys


def scan(fname):
    src = io.open(fname, encoding="utf-8").read()
    # Drop -- comments so apostrophes in prose do not confuse the scan.
    lines = []
    for ln in src.splitlines():
        idx = ln.find("--")
        if idx != -1 and ln[:idx].count("'") % 2 == 0:
            ln = ln[:idx]
        lines.append(ln)
    body = "\n".join(lines)

    i, literals, closed = 0, 0, True
    while i < len(body):
        if body[i] != "'":
            i += 1
            continue
        literals += 1
        i += 1
        while i < len(body):
            if body[i] == "'":
                if i + 1 < len(body) and body[i + 1] == "'":
                    i += 2
                    continue
                i += 1
                break
            i += 1
        else:
            closed = False
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
