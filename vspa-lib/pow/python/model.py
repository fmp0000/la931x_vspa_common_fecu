# SPDX-License-Identifier: BSD-3-Clause
"""Python model for pow_acc_asm kernel."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

from vspa.arith import _f64_to_f32_trunc
from vspa.io import _float_to_sm16


def _sm16_decode(u16):
    sign = (u16 >> 15).astype(np.float64)
    mag = (u16 & 0x7FFF).astype(np.float64) / 32768.0
    return np.where(sign == 0, mag, -mag)


def r_pow_acc(inp: np.ndarray, n_per_line: int = 32):
    x = np.asarray(inp, dtype=np.complex128).reshape(-1)

    re_bits = _float_to_sm16(x.real).astype(np.uint16)
    im_bits = _float_to_sm16(x.imag).astype(np.uint16)
    re_f = _sm16_decode(re_bits)
    im_f = _sm16_decode(im_bits)

    acc = np.zeros(n_per_line, dtype=np.float64)
    for j in range(len(x)):
        slot = j % n_per_line
        t1 = _f64_to_f32_trunc(re_f[j] * re_f[j])
        t2 = _f64_to_f32_trunc(im_f[j] * im_f[j])
        delta = _f64_to_f32_trunc(t1 + t2)
        acc[slot] = _f64_to_f32_trunc(acc[slot] + delta)

    return _f64_to_f32_trunc(acc).astype(np.float32)
