# SPDX-License-Identifier: BSD-3-Clause
"""Hex file helpers shared by vector generators."""

import numpy as np


def write_hex_u16(values, path: str) -> None:
    """Write uint16 values as a C-includable hex file."""
    with open(path, 'w') as handle:
        for value in values:
            handle.write(f'0x{int(value) & 0xFFFF:04X},\n')


def write_hex_u32(values, path: str) -> None:
    """Write uint32 values as a C-includable hex file."""
    with open(path, 'w') as handle:
        for value in values:
            handle.write(f'0x{int(value) & 0xFFFFFFFF:08X},\n')


def read_hex_u16(path: str) -> np.ndarray:
    """Read uint16 values from a C-includable hex file."""
    values = []
    with open(path) as handle:
        for line in handle:
            line = line.strip().rstrip(',')
            if line:
                values.append(int(line, 16) & 0xFFFF)
    return np.array(values, dtype=np.uint16)


def read_hex_u32(path: str) -> np.ndarray:
    """Read uint32 values from a C-includable hex file."""
    values = []
    with open(path) as handle:
        for line in handle:
            line = line.strip().rstrip(',')
            if line:
                values.append(int(line, 16) & 0xFFFFFFFF)
    return np.array(values, dtype=np.uint32)