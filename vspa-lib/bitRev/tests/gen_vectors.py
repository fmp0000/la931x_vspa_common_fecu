#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for bitRev64 end-to-end test using local python/model.py."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys

import numpy as np

_TESTS_DIR = Path(__file__).resolve().parent
_KERNEL_DIR = _TESTS_DIR.parent
_COMMON_PY = _KERNEL_DIR.parent / 'common' / 'python'

for p in (str(_COMMON_PY), str(_KERNEL_DIR / 'python')):
    if p not in sys.path:
        sys.path.insert(0, p)

from utils.hex_io import write_hex_u32
from model import r_bitrev64

OUTDIR = _TESTS_DIR / 'vectors'
N = 64


def complex_to_packed_f16(c: np.ndarray) -> np.ndarray:
    """Pack complex float16 as uint32: [imag(31:16) | real(15:0)]."""
    c = np.asarray(c)
    re_bits = np.frombuffer(c.real.astype(np.float16).tobytes(), dtype=np.uint16).astype(np.uint32)
    im_bits = np.frombuffer(c.imag.astype(np.float16).tobytes(), dtype=np.uint16).astype(np.uint32)
    return (im_bits << 16) | re_bits


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument('--seed', type=int, default=42)
    args = p.parse_args()

    rng = np.random.default_rng(args.seed)

    x_reord = rng.uniform(-0.9, 0.9, N) + 1j * rng.uniform(-0.9, 0.9, N)
    y = r_bitrev64(x_reord)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(complex_to_packed_f16(x_reord), str(OUTDIR / 'input.hex'))
    write_hex_u32(complex_to_packed_f16(y), str(OUTDIR / 'ref.hex'))

    print(f'Generated bitRev64 vectors: N={N}, seed={args.seed}')


if __name__ == '__main__':
    main()
