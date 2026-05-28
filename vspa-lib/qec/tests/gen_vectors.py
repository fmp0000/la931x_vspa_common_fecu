#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate qec vectors for all-zero-parameter smoke regime."""

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

from model import r_qec_zero_params
from utils.hex_io import write_hex_u16
from vspa.io import _float_to_sm16

OUTDIR = _TESTS_DIR / 'vectors'
N_SAMPLES = 128


def interleave_sm16(c):
    re_ = _float_to_sm16(np.asarray(c).real)
    im_ = _float_to_sm16(np.asarray(c).imag)
    out = np.empty(2 * len(re_), dtype=np.uint16)
    out[0::2] = re_
    out[1::2] = im_
    return out


def main() -> None:
    rng = np.random.default_rng(7)
    x = rng.uniform(-0.7, 0.7, N_SAMPLES) + 1j * rng.uniform(-0.7, 0.7, N_SAMPLES)
    y_ref = r_qec_zero_params(x)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u16(interleave_sm16(x), str(OUTDIR / 'input.hex'))
    write_hex_u16(interleave_sm16(y_ref), str(OUTDIR / 'ref.hex'))

    print(f'Generated qec vectors: N_SAMPLES={N_SAMPLES} (zero-parameter regime)')


if __name__ == '__main__':
    main()
