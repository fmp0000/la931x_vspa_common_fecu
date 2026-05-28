# SPDX-License-Identifier: BSD-3-Clause
"""Python model for phase_compensation kernel."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_COMMON = Path(__file__).resolve().parents[2] / 'common' / 'python'
if str(_COMMON) not in sys.path:
    sys.path.insert(0, str(_COMMON))

from vspa.arith import r_half, r_smad


def r_phase_compensation(inp: np.ndarray, coeff: complex):
    x = np.asarray(inp, dtype=np.complex128).reshape(-1)
    c = np.float32(np.real(coeff)).astype(np.float64) + 1j * np.float32(np.imag(coeff)).astype(np.float64)
    return r_half(r_smad(c, x, 0))
