# SPDX-License-Identifier: BSD-3-Clause
"""Python model for txWindowing_w16_vecaligned kernel."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

from vspa.arith import r_convert


def r_tx_windowing(inp_out, hist, win):
    inp_out = np.asarray(inp_out, dtype=np.complex128)
    hist = np.asarray(hist, dtype=np.complex128)
    win = np.asarray(win, dtype=np.float64).real

    w_len = len(win)
    if len(inp_out) < 2 * w_len:
        raise ValueError(f'r_tx_windowing: inp_out length {len(inp_out)} < 2*W={2*w_len}')
    if len(hist) != w_len:
        raise ValueError(f'r_tx_windowing: hist length {len(hist)} != W={w_len}')

    head_in = r_convert(inp_out[:w_len], 'half_fixed')
    tail_in = r_convert(inp_out[-w_len:], 'half_fixed')
    hist_in = r_convert(hist, 'half_fixed')
    win_q = r_convert(win, 'half')

    head_out = r_convert(win_q * head_in + hist_in, 'half_fixed')
    new_hist = r_convert((1.0 - win_q) * tail_in, 'half_fixed')

    inp_out[:w_len] = head_out
    inp_out[-w_len:] = tail_in
    hist[:] = new_hist
    return inp_out, hist
