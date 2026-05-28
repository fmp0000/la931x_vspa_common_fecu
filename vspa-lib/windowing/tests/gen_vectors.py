#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for txWindowing_w16_vecaligned using local python/model.py."""

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

from model import r_tx_windowing
from utils.hex_io import write_hex_u32
from utils.packing import complex_to_u32_sm16, u32_to_complex_sm16

OUTDIR = _TESTS_DIR / 'vectors'
N = 32
W = 16
SEED = 42


def pack_window_f16(win_real: np.ndarray) -> np.ndarray:
    f16 = win_real.astype(np.float16).view(np.uint16)
    packed = np.zeros(N, dtype=np.uint32)
    for k in range(W // 2):
        packed[k] = (np.uint32(f16[2 * k + 1]) << 16) | np.uint32(f16[2 * k])
    return packed


def main() -> None:
    rng = np.random.default_rng(SEED)

    raw = rng.uniform(-0.7, 0.7, N) + 1j * rng.uniform(-0.7, 0.7, N)
    inp = u32_to_complex_sm16(complex_to_u32_sm16(raw))

    win_real = np.sin(np.pi * np.arange(W) / (2 * W)) ** 2
    win_f16 = win_real.astype(np.float16).astype(np.float64)

    hist = np.zeros(W, dtype=np.complex128)
    inp_out = inp.copy()
    r_tx_windowing(inp_out, hist, win_f16)

    input_u32 = complex_to_u32_sm16(inp)
    ref_u32 = complex_to_u32_sm16(inp_out)
    hist_u32 = np.zeros(N, dtype=np.uint32)
    win_u32 = pack_window_f16(win_real)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(input_u32, str(OUTDIR / 'input.hex'))
    write_hex_u32(ref_u32, str(OUTDIR / 'ref.hex'))
    write_hex_u32(hist_u32, str(OUTDIR / 'hist_in.hex'))
    write_hex_u32(win_u32, str(OUTDIR / 'win.hex'))

    print(f'Generated windowing vectors (N={N}, W={W}, seed={SEED})')


if __name__ == '__main__':
    main()
