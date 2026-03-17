"""
SHA-256 hash key generation matching SQL Server's core.SHA256Hash().

SQL Server computes: HASHBYTES('SHA2_256', CAST(@input AS VARBINARY(MAX)))
where @input is NVARCHAR(MAX). CAST(NVARCHAR → VARBINARY) produces UTF-16LE bytes.
Python must encode as UTF-16LE to produce identical hashes.

Hub hash formula: SHA256(CONCAT_WS('|', business_key, src_schema))
Link hash formula: SHA256(CONCAT_WS('|', hub_id_1_hex, hub_id_2_hex, ..., src_schema))
"""
import hashlib


def _sha256_sql(input_str: str) -> bytes:
    """Compute SHA-256 the same way SQL Server does on NVARCHAR input."""
    return hashlib.sha256(input_str.encode("utf-16-le")).digest()


def make_hub_id(business_key: str, src: str) -> bytes:
    """Generate a HUB_ID matching SQL Server's hash formula."""
    return _sha256_sql(f"{business_key}|{src}")


def make_lnk_id(*hub_ids: bytes, src: str) -> bytes:
    """Generate a LNK_ID from constituent hub IDs + src."""
    parts = [h.hex() for h in hub_ids]
    parts.append(src)
    return _sha256_sql("|".join(parts))


def to_hex(hash_bytes: bytes) -> str:
    """Convert BINARY(32) to 64-char uppercase hex string for CSV output."""
    return hash_bytes.hex().upper()
