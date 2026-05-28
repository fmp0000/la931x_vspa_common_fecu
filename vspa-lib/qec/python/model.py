# SPDX-License-Identifier: BSD-3-Clause
"""Minimal Python model for qec smoke tests.

Current migrated harness validates the all-zero parameter regime where
qec_opt_asm output is identically zero for any input.
"""

from __future__ import annotations

import numpy as np


def r_qec_zero_params(inp: np.ndarray) -> np.ndarray:
    x = np.asarray(inp, dtype=np.complex128).reshape(-1)
    return np.zeros_like(x)
