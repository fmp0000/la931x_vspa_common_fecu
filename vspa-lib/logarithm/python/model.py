# SPDX-License-Identifier: BSD-3-Clause
"""Python model for logarithm kernel (log_asm)."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

from vspa.arith import r_smad, r_single

_LOG_M = 5
_LOG_Q = 16

LOG_FACT_VALUES = {
    'LOG2x1': np.float32(1.0),
    'LOG10x10': np.float32(10.0 * np.log10(2.0)),
    'LOG10x20': np.float32(20.0 * np.log10(2.0)),
}


def _build_log_table(M: int = _LOG_M, Q: int = _LOG_Q):
    x1 = 1.0 + np.arange(2 ** M) * 2.0 ** (-M)
    mid = x1 + 2.0 ** (-M - 1)
    knots_x = np.append(x1, 2.0)
    knots_y = np.append(np.log2(x1), 1.0)
    interp = np.interp(mid, knots_x, knots_y)
    e = np.log2(mid) - interp
    e[0] = 0.0
    e[1:] = e[1:] + 0.42e-4
    y = np.log2(x1) + e / 2.0
    y_log = np.round(y * 2.0 ** Q).astype(np.int64)
    diff_y = np.append(np.diff(y), 1.0 - y[-1])
    m_log = np.round(diff_y * 2.0 ** Q).astype(np.int64)
    return y_log, m_log


_Y_LOG, _M_LOG = _build_log_table()


def r_log2(x, M: int = _LOG_M, Q: int = _LOG_Q):
    x = np.asarray(r_single(x), dtype=np.float64)
    exp_x = np.floor(np.log2(x))
    man_x = x / (2.0 ** exp_x)
    x_rnd = np.floor((man_x - 1.0) * 2.0 ** (Q + 1)) / 2.0 ** (Q + 1)
    idx = np.floor(x_rnd * 2.0 ** M).astype(np.int64)
    idx = np.clip(idx, 0, 2 ** M - 1)
    rem = np.floor(np.mod(x_rnd * 2.0 ** Q, 2.0 ** (Q - M))).astype(np.int64)
    num = (1 << (Q - M)) * _Y_LOG[idx] + _M_LOG[idx] * rem
    frac_y = num.astype(np.float64) / 2.0 ** (2 * Q - M)
    frac_y = np.floor(frac_y * 2.0 ** Q) / 2.0 ** Q
    return exp_x + frac_y


def _float2fix_q15(flt):
    flt = np.asarray(r_single(flt), dtype=np.float64)
    int_part = np.floor(flt).astype(np.int64)
    frac = np.floor((flt - int_part) * 2 ** 15).astype(np.int64)
    fixed = (int_part * (1 << 15) + frac) & 0xFFFFFFFF
    return fixed.astype(np.uint32)


def r_log(x, fact):
    x_arr = np.asarray(x, dtype=np.float64)
    shape = x_arr.shape
    flat = x_arr.ravel()

    log2_v = r_log2(flat)
    fixed = _float2fix_q15(log2_v)
    sint = np.frombuffer(fixed.astype('<u4').tobytes(), dtype='<i4').astype(np.float64)
    log2_q15 = sint / 2.0 ** 15

    log2_int = np.floor(log2_q15)
    log2_frac = log2_q15 - log2_int

    out = r_smad(np.float64(fact), log2_int, 0.0)
    out = r_smad(np.float64(fact), log2_frac, out)
    return out.astype(np.float32).reshape(shape)
