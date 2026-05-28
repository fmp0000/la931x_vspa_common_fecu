#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for mixer_asm using local python/model.py."""

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

from model import r_mixer
from utils.hex_io import write_hex_u16
from vspa.io import _float_to_sm16, _sm16_to_float

OUTDIR = _TESTS_DIR / 'vectors'
AU = 16
LINES = 2
N_CPLX = LINES * (AU * 2)
PHASE_IN = 0x12345678
FREQ_IN = 0x00123456


def interleave_sm16(c: np.ndarray) -> np.ndarray:
    re_ = _float_to_sm16(np.asarray(c).real)
    im_ = _float_to_sm16(np.asarray(c).imag)
    out = np.empty(2 * len(re_), dtype=np.uint16)
    out[0::2] = re_
    out[1::2] = im_
    return out


def main() -> None:
    rng = np.random.default_rng(42)
    x_raw = rng.uniform(-0.7, 0.7, N_CPLX) + 1j * rng.uniform(-0.7, 0.7, N_CPLX)

    x_re_sm = _float_to_sm16(x_raw.real)
    x_im_sm = _float_to_sm16(x_raw.imag)
    x = _sm16_to_float(x_re_sm) + 1j * _sm16_to_float(x_im_sm)

    y = r_mixer(x, PHASE_IN, FREQ_IN)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u16(interleave_sm16(x), str(OUTDIR / 'input.hex'))
    write_hex_u16(interleave_sm16(y), str(OUTDIR / 'ref.hex'))

    print(f'Generated mixer vectors: L={LINES}, N={N_CPLX}, phase=0x{PHASE_IN:08X}, freq=0x{FREQ_IN:08X}')


if __name__ == '__main__':
    main()
