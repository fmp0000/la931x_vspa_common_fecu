#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for pow_acc_asm using local python/model.py."""

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

from model import r_pow_acc
from utils.hex_io import write_hex_u32
from vspa.io import _float_to_sm16

OUTDIR = _TESTS_DIR / 'vectors'
N_PER_LINE = 32
N_LINES = 8
N_SAMPLES = N_PER_LINE * N_LINES


def main() -> None:
    rng = np.random.default_rng(42)
    re = rng.uniform(-0.7, 0.7, N_SAMPLES)
    im = rng.uniform(-0.7, 0.7, N_SAMPLES)

    re_bits = _float_to_sm16(re).astype(np.uint16)
    im_bits = _float_to_sm16(im).astype(np.uint16)
    input_u32 = (im_bits.astype(np.uint32) << 16) | re_bits.astype(np.uint32)

    acc_f32 = r_pow_acc(re + 1j * im, n_per_line=N_PER_LINE)
    ref_u32 = np.frombuffer(acc_f32.tobytes(), dtype='<u4')

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(input_u32, str(OUTDIR / 'input.hex'))
    write_hex_u32(ref_u32, str(OUTDIR / 'ref.hex'))

    print(f'Generated pow vectors: {N_SAMPLES} complex samples ({N_LINES} lines)')


if __name__ == '__main__':
    main()
