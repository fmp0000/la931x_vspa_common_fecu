# SPDX-License-Identifier: BSD-3-Clause
"""Python model for decimator_2x_8_Taps_asm in resample_ddc_interp."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

from vspa.arith import r_convert, r_smad


def r_decimator_2x(inp, flt, inp_hist=None,
                   input_prec='half_fixed', filter_prec='single', output_prec='half_fixed'):
    inp = np.asarray(inp, dtype=np.complex128).reshape(-1)
    flt = np.asarray(flt, dtype=np.float64).reshape(-1)

    if np.iscomplexobj(flt) and np.any(flt.imag != 0):
        raise ValueError('Decimator FIR filter must be real')
    if len(flt) % 2 != 0:
        raise ValueError('Decimator FIR filter length must be even')
    if len(inp) % 2 != 0:
        raise ValueError('Decimator input length must be even')

    if inp_hist is None:
        inp_hist = np.zeros(len(flt) - 1, dtype=np.complex128)
    inp_hist = np.asarray(inp_hist, dtype=np.complex128).reshape(-1)
    if inp_hist.shape != (len(flt) - 1,):
        raise ValueError('Decimator input history size mismatch')

    inp_v = r_convert(inp, input_prec)
    inp_hist_v = r_convert(inp_hist, input_prec)
    flt_v = r_convert(flt.real, filter_prec)[::-1]

    inp_v_p = np.concatenate([inp_hist_v, inp_v])
    inp_len = len(inp_v)
    acc_lanes = np.zeros(inp_len, dtype=np.float64)

    for iter_idx in range(len(flt_v) // 2):
        h0 = flt_v[2 * iter_idx]
        h1 = flt_v[2 * iter_idx + 1]
        aux = inp_v_p[2 * iter_idx: 2 * iter_idx + inp_len]

        s1 = np.empty(inp_len, dtype=np.complex128)
        s1[0::2] = aux[1::2].real + 1j * aux[0::2].real
        s1[1::2] = aux[1::2].imag + 1j * aux[0::2].imag
        acc_lanes = np.imag(r_smad(h0 + 1j * h1, s1, 1j * acc_lanes))

    out_v = acc_lanes[0::2] + 1j * acc_lanes[1::2]
    next_hist = inp_v_p[-(len(flt_v) - 1):]
    return r_convert(out_v, output_prec), next_hist
