# SPDX-License-Identifier: BSD-3-Clause
"""
Bit-exact Python model for the NXP VSPA decimator kernel.

Ported from:
  submodules/la931x_vspa_common/vspa-lib/decimator/matlab/r_decimator.m
  submodules/la931x_vspa_common/vspa-lib/decimator/matlab/r_decimator_2x.m

Depends only on the shared VSPA primitives under
  submodules/la931x_vspa_common/vspa-lib/common/python/

Public API:
    r_decimator_2x(inp, flt, ...)  — single 2x decimation stage
    r_decimator(inp, flt, factor, ...) — cascaded 2x/4x/8x
"""

from __future__ import annotations

from pathlib import Path
import sys

# Make common/python importable without requiring an installed package.
_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

import numpy as np
from vspa.arith import r_convert, r_smad


def r_decimator_2x(
    inp,
    flt,
    inp_hist=None,
    input_prec: str = 'half_fixed',
    filter_prec: str = 'single',
    output_prec: str = 'half_fixed',
):
    """Bit-exact 2x decimator model for decimator_2x_32hf / decimator_asm.

    Args:
        inp        : complex input samples, length N (N must be even).
        flt        : real FIR tap coefficients, length L (L must be even).
        inp_hist   : complex history from previous call, length L-1; zeros if None.
        input_prec : input quantisation ('half_fixed' | 'half' | 'single' | 'double').
        filter_prec: tap quantisation.
        output_prec: output quantisation.

    Returns:
        (out, next_hist)
        out       : complex output, length N/2.
        next_hist : history for the next block call.
    """
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

    inp_v      = r_convert(inp,          input_prec)
    inp_hist_v = r_convert(inp_hist,     input_prec)
    flt_v      = r_convert(flt.real,     filter_prec)[::-1]

    inp_v_p  = np.concatenate([inp_hist_v, inp_v])
    inp_len  = len(inp_v)
    acc_lanes = np.zeros(inp_len, dtype=np.float64)

    for iter_idx in range(len(flt_v) // 2):
        h0 = flt_v[2 * iter_idx]
        h1 = flt_v[2 * iter_idx + 1]
        aux = inp_v_p[2 * iter_idx : 2 * iter_idx + inp_len]

        s1 = np.empty(inp_len, dtype=np.complex128)
        s1[0::2] = aux[1::2].real + 1j * aux[0::2].real
        s1[1::2] = aux[1::2].imag + 1j * aux[0::2].imag
        acc_lanes = np.imag(r_smad(h0 + 1j * h1, s1, 1j * acc_lanes))

    out_v      = acc_lanes[0::2] + 1j * acc_lanes[1::2]
    next_hist  = inp_v_p[-(len(flt_v) - 1):]
    return r_convert(out_v, output_prec), next_hist


def r_decimator(
    inp,
    flt,
    factor: int,
    num_blocks: int = 1,
    input_prec: str = 'half_fixed',
    filter_prec: str = 'single',
    output_prec: str = 'half_fixed',
    inp_hist=None,
):
    """Bit-exact cascaded decimator for factors 2x, 4x, and 8x.

    Cascades r_decimator_2x stages, each using the same filter.
    """
    if factor not in (2, 4, 8):
        raise ValueError(f'Decimation factor {factor} not supported')

    inp    = np.asarray(inp, dtype=np.complex128).reshape(-1)
    flt    = np.asarray(flt, dtype=np.float64).reshape(-1)
    stages = int(np.log2(factor))

    if num_blocks <= 0 or len(inp) % num_blocks != 0:
        raise ValueError('Decimator input length is not divisible by the number of blocks')

    if inp_hist is None:
        inp_hist = np.zeros((len(flt) - 1, stages), dtype=np.complex128)
    inp_hist = np.asarray(inp_hist, dtype=np.complex128)
    if inp_hist.shape != (len(flt) - 1, stages):
        raise ValueError('Decimator input history size mismatch')

    hist_state = inp_hist.copy()
    inp_blocks = inp.reshape(-1, num_blocks, order='F')
    out_blocks = []

    for block_idx in range(num_blocks):
        stage_out = inp_blocks[:, block_idx]
        for stage_idx in range(stages):
            stage_out, hist_state[:, stage_idx] = r_decimator_2x(
                stage_out,
                flt,
                inp_hist=hist_state[:, stage_idx],
                input_prec=input_prec,
                filter_prec=filter_prec,
                output_prec=output_prec,
            )
        out_blocks.append(stage_out)

    return np.concatenate(out_blocks), hist_state
