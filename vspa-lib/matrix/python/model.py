# SPDX-License-Identifier: BSD-3-Clause
"""Python model for matrix batch multiply kernels."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

from vspa.arith import r_convert, r_smad


def r_mat_bmult(vec, mat, vec_prec, mat_prec, out_prec, mat_interp: int = 1):
    vec = np.asarray(vec, dtype=np.complex128)
    mat = np.asarray(mat, dtype=np.complex128)

    if mat_interp > 1:
        mat = np.repeat(mat, mat_interp, axis=0)

    dim1 = vec.shape[0]
    dim2 = vec.shape[1]
    dim3 = mat.shape[1]

    vec_v = r_convert(vec, vec_prec)
    mat_v = r_convert(mat, mat_prec)

    out_v = np.zeros((dim1, dim3), dtype=np.complex128)
    for out_idx in range(dim3):
        for inp_idx in range(dim2):
            s0 = vec_v[:, inp_idx]
            s1 = mat_v[:, out_idx, inp_idx]
            v = out_v[:, out_idx]
            out_v[:, out_idx] = r_smad(s0, s1, v)

    return r_convert(out_v, out_prec)
