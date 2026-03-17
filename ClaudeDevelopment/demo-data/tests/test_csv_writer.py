"""Tests for csv_writer — verifies pipe-delimited format, type handling, BOM."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import pytest
from csv_writer import DvCsvWriter
from datetime import datetime


def test_creates_file_with_bom(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["COL_A", "COL_B"])
    w.close()
    raw = path.read_bytes()
    assert raw[:3] == b"\xef\xbb\xbf"


def test_header_row(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["HUB_ID", "SRC", "LOAD_TS"])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[0] == "HUB_ID|SRC|LOAD_TS"


def test_pipe_delimiter(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["A", "B", "C"])
    w.writerow(["x", "y", "z"])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "x|y|z"


def test_none_as_empty(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["A", "B"])
    w.writerow(["x", None])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "x|"


def test_binary_as_hex(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["HUB_ID"])
    w.writerow([b"\x00" * 32])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "0" * 64


def test_datetime_format(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["TS"])
    w.writerow([datetime(2025, 10, 1, 14, 30, 0)])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "2025-10-01T14:30:00.0000000"


def test_bool_as_bit(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["FLAG"])
    w.writerow([True])
    w.writerow([False])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "1"
    assert lines[2] == "0"


def test_decimal_no_currency(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["PRICE"])
    w.writerow([12.50])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "12.50"


def test_row_count(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["A"])
    w.writerow(["1"])
    w.writerow(["2"])
    w.writerow(["3"])
    w.close()
    assert w.row_count == 3


def test_context_manager(tmp_path):
    path = tmp_path / "test.csv"
    with DvCsvWriter(str(path), ["A"]) as w:
        w.writerow(["x"])
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert len(lines) == 2
