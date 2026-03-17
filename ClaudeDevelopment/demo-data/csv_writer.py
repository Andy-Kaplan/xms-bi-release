"""
Pipe-delimited CSV writer for Data Vault table CSVs.

Format conventions:
- UTF-8 with BOM (SQL Server BULK INSERT expects BOM)
- Pipe '|' delimiter (product names contain commas)
- BINARY(32): 64-char uppercase hex, no 0x prefix
- datetime2: ISO 8601 YYYY-MM-DDTHH:MM:SS.nnnnnnn
- NULL: empty string
- bit: 1 or 0
- decimal: plain numeric
"""
from datetime import datetime, date
from pathlib import Path


class DvCsvWriter:
    def __init__(self, filepath: str, columns: list[str]):
        self.filepath = filepath
        self.columns = columns
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        self._f = open(filepath, "w", encoding="utf-8-sig", newline="")
        self._f.write("|".join(columns) + "\n")
        self._row_count = 0

    def writerow(self, values: list):
        parts = [self._format(v) for v in values]
        self._f.write("|".join(parts) + "\n")
        self._row_count += 1

    def close(self):
        self._f.close()

    @property
    def row_count(self):
        return self._row_count

    @staticmethod
    def _format(value) -> str:
        if value is None:
            return ""
        if isinstance(value, bytes):
            return value.hex().upper()
        if isinstance(value, bool):
            return "1" if value else "0"
        if isinstance(value, datetime):
            return value.strftime("%Y-%m-%dT%H:%M:%S.") + "0000000"
        if isinstance(value, date):
            return value.strftime("%Y-%m-%dT00:00:00.") + "0000000"
        if isinstance(value, float):
            s = f"{value:.10f}"
            integer_part, decimal_part = s.split('.')
            decimal_part = decimal_part.rstrip('0')
            if len(decimal_part) < 2:
                decimal_part = decimal_part.ljust(2, '0')
            return f"{integer_part}.{decimal_part}"
        return str(value)

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
