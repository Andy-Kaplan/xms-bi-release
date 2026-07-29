"""Regression tests for check_literals.scan().

Run: python test_check_literals.py

Covers the blind spot in the old implementation: it decided whether a '--'
was a real comment using only that line's own quote count, with no carried
-over state for a literal opened on an earlier line. Case 3 below is the
concrete fixture that the old scan gets wrong (proven against a frozen copy
of the old implementation, see the docstring on OLD_SCAN below).
"""
import io
import os
import tempfile

from check_literals import scan


def _write(tmpdir, name, content):
    path = os.path.join(tmpdir, name)
    io.open(path, "w", encoding="utf-8", newline="\n").write(content)
    return path


def test_correctly_doubled_quotes_ok():
    with tempfile.TemporaryDirectory() as tmp:
        path = _write(
            tmp,
            "case1.sql",
            "SELECT N'it''s a test' AS Col;\n",
        )
        literals, closed = scan(path)
        assert literals == 1
        assert closed is True


def test_unterminated_literal_fails():
    with tempfile.TemporaryDirectory() as tmp:
        path = _write(
            tmp,
            "case2.sql",
            "SELECT N'this literal never closes AS Col;\n",
        )
        literals, closed = scan(path)
        assert literals == 1
        assert closed is False


def test_line_inside_literal_starting_with_dashdash_terminates_correctly():
    """The case the old implementation got wrong.

    The literal opens on line 1 and does not close there. Line 2 begins
    with '--' but is really the continuation of that open literal; it
    contains a single (lone, un-doubled) quote that legitimately ends the
    literal, followed by real SQL on the same line.

    The old per-line pre-pass decided '--' was a real comment because line
    2 *on its own* has an even (zero) quote count before the '--', so it
    truncated the whole line away -- deleting the terminating quote and
    making a genuinely valid, closed literal look unterminated.

    Proven empirically: running the frozen old scan() against this exact
    fixture returns (1, False) -- a false failure. The fixed scan() must
    return (1, True).
    """
    with tempfile.TemporaryDirectory() as tmp:
        path = _write(
            tmp,
            "case3.sql",
            "SELECT N'abc\n"
            "--this line is inside the literal and has a lone quote that ends it' AND 1 = 1;\n",
        )
        literals, closed = scan(path)
        assert literals == 1
        assert closed is True


def test_apostrophe_inside_real_line_comment_is_ok():
    with tempfile.TemporaryDirectory() as tmp:
        path = _write(
            tmp,
            "case4.sql",
            "SELECT 1; -- don't strip me wrongly\n",
        )
        literals, closed = scan(path)
        assert literals == 0
        assert closed is True


def test_unmatched_quote_inside_block_comment_is_ok():
    with tempfile.TemporaryDirectory() as tmp:
        path = _write(
            tmp,
            "case5.sql",
            "/* this block comment has an unmatched ' quote in it\n"
            "   spanning multiple lines */\n"
            "SELECT 1;\n",
        )
        literals, closed = scan(path)
        assert literals == 0
        assert closed is True


def _run_against_old_implementation_for_proof():
    """Not part of the assertion suite -- documents the old-vs-new divergence.

    Reconstructs the old (pre-fix) scan() verbatim and runs it against the
    case-3 fixture to show it reports a false failure, which is what
    motivated the rewrite. Printed for the record when this file is run
    directly; does not affect the pass/fail exit code of the main suite.
    """

    def old_scan(fname):
        src = io.open(fname, encoding="utf-8").read()
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

    with tempfile.TemporaryDirectory() as tmp:
        path = _write(
            tmp,
            "case3.sql",
            "SELECT N'abc\n"
            "--this line is inside the literal and has a lone quote that ends it' AND 1 = 1;\n",
        )
        old_result = old_scan(path)
        new_result = scan(path)
        print(f"  old_scan(case3) = {old_result}  (false failure: closed should be True)")
        print(f"  new_scan(case3) = {new_result}  (correct)")
        assert old_result == (1, False), "expected old implementation to misreport this fixture"
        assert new_result == (1, True), "expected fixed implementation to report it correctly"


def main():
    tests = [
        test_correctly_doubled_quotes_ok,
        test_unterminated_literal_fails,
        test_line_inside_literal_starting_with_dashdash_terminates_correctly,
        test_apostrophe_inside_real_line_comment_is_ok,
        test_unmatched_quote_inside_block_comment_is_ok,
    ]
    for t in tests:
        t()
        print(f"PASS {t.__name__}")

    print("\nProof that case 3 distinguishes old vs new implementation:")
    _run_against_old_implementation_for_proof()
    print("PASS _run_against_old_implementation_for_proof")

    print("\nAll tests passed.")


if __name__ == "__main__":
    main()
