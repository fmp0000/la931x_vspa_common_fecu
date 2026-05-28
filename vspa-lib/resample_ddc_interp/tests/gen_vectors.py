#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate decimator_2x_8_Taps vectors using local python/model.py."""

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

from model import r_decimator_2x
from utils.hex_io import write_hex_u16
from vspa.io import _float_to_sm16

OUTDIR = _TESTS_DIR / 'vectors'
NUM_TAPS = 8
N_IN = 128
N_OUT = N_IN // 2

FILTER_TAPS_U32 = np.array([
    0xBE0263BE, 0xBDE8A4F0, 0x3EA45618, 0x3F5B3BFF,
    0x3F5B3BFF, 0x3EA45618, 0xBDE8A4F0, 0xBE0263BE
], dtype=np.uint32)


def interleave_sm16(c):
    re_ = _float_to_sm16(np.asarray(c).real)
    im_ = _float_to_sm16(np.asarray(c).imag)
    out = np.empty(2 * len(re_), dtype=np.uint16)
    out[0::2] = re_
    out[1::2] = im_
    return out


def main() -> None:
    rng = np.random.default_rng(42)
    x = rng.uniform(-0.7, 0.7, N_IN) + 1j * rng.uniform(-0.7, 0.7, N_IN)

    taps = FILTER_TAPS_U32.view('<f4').astype(np.float64)
    y_full, _ = r_decimator_2x(
        x, taps,
        inp_hist=np.zeros(NUM_TAPS - 1, dtype=np.complex128),
        input_prec='half_fixed', filter_prec='single', output_prec='half_fixed'
    )
    y_out = y_full[:N_OUT]

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u16(interleave_sm16(x), str(OUTDIR / 'input.hex'))
    write_hex_u16(interleave_sm16(y_out), str(OUTDIR / 'ref.hex'))

    print(f'Generated resample_ddc_interp vectors: N_IN={N_IN}, N_OUT={N_OUT}, NUM_TAPS={NUM_TAPS}')


if __name__ == '__main__':
    main()
