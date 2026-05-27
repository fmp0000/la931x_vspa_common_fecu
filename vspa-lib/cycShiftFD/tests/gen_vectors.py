#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate cycShiftFD vectors using local python/model.py."""

from __future__ import annotations

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
from model import r_cycShiftFD
from vspa.arith import r_half_flt

OUTDIR = _TESTS_DIR / 'vectors'
N = 64
SHIFT = 8


def complex_f16_to_packed_u32(c: np.ndarray) -> np.ndarray:
    """Pack complex float16 as (im_bits << 16) | re_bits."""
    c = np.asarray(c)
    re_bits = np.frombuffer(c.real.astype(np.float16).tobytes(), dtype=np.uint16).astype(np.uint32)
    im_bits = np.frombuffer(c.imag.astype(np.float16).tobytes(), dtype=np.uint16).astype(np.uint32)
    return (im_bits << 16) | re_bits


def main() -> None:
    rng = np.random.default_rng(42)
    x = rng.uniform(-0.7, 0.7, N) + 1j * rng.uniform(-0.7, 0.7, N)
    x = r_half_flt(x)
    y = r_cycShiftFD(x, SHIFT, N)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(complex_f16_to_packed_u32(x), str(OUTDIR / 'input.hex'))
    write_hex_u32(complex_f16_to_packed_u32(y), str(OUTDIR / 'ref.hex'))

    nco_freq = round((SHIFT * 2 ** 32) / N) / 2 ** 32
    print(f'Generated cycShiftFD vectors: N={N}, SHIFT={SHIFT}, nco_freq={nco_freq:.10f}')


if __name__ == '__main__':
    main()
