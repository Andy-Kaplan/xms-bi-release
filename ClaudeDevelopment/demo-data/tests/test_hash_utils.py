"""Tests for hash_utils — verifies SHA-256 output matches SQL Server's core.SHA256Hash()."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import pytest
import hashlib
from hash_utils import make_hub_id, make_lnk_id, to_hex


def test_hub_id_is_32_bytes():
    result = make_hub_id("PROD001", "int_ncraloha001")
    assert isinstance(result, bytes)
    assert len(result) == 32


def test_hub_id_deterministic():
    a = make_hub_id("PROD001", "int_ncraloha001")
    b = make_hub_id("PROD001", "int_ncraloha001")
    assert a == b


def test_hub_id_different_keys():
    a = make_hub_id("PROD001", "int_ncraloha001")
    b = make_hub_id("PROD002", "int_ncraloha001")
    assert a != b


def test_hub_id_different_src():
    a = make_hub_id("PROD001", "int_ncraloha001")
    b = make_hub_id("PROD001", "int_marketman001")
    assert a != b


def test_hub_id_hex_roundtrip():
    h = make_hub_id("PROD001", "int_ncraloha001")
    hex_str = h.hex()
    assert len(hex_str) == 64
    assert bytes.fromhex(hex_str) == h


def test_lnk_id_from_two_hubs():
    hub1 = make_hub_id("LI001", "int_ncraloha001")
    hub2 = make_hub_id("PROD001", "int_ncraloha001")
    lnk = make_lnk_id(hub1, hub2, src="int_ncraloha001")
    assert isinstance(lnk, bytes)
    assert len(lnk) == 32


def test_lnk_id_deterministic():
    hub1 = make_hub_id("LI001", "int_ncraloha001")
    hub2 = make_hub_id("PROD001", "int_ncraloha001")
    a = make_lnk_id(hub1, hub2, src="int_ncraloha001")
    b = make_lnk_id(hub1, hub2, src="int_ncraloha001")
    assert a == b


def test_utf16le_encoding():
    input_str = "test|int_ncraloha001"
    expected = hashlib.sha256(input_str.encode("utf-16-le")).digest()
    result = make_hub_id("test", "int_ncraloha001")
    assert result == expected


def test_to_hex_uppercase():
    h = make_hub_id("PROD001", "int_ncraloha001")
    hex_str = to_hex(h)
    assert len(hex_str) == 64
    assert hex_str == hex_str.upper()
