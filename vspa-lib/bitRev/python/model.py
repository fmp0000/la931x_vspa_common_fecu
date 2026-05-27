# SPDX-License-Identifier: BSD-3-Clause
"""Python model for bit-reversal kernels (bitRev).

Current API mirrors the tested bitRev64 flow used by the asm harness.
"""

from __future__ import annotations

import numpy as np


def bitrev_indices(n: int) -> np.ndarray:
    """Return indices for bit-reversal permutation on [0, n-1]."""
    if n <= 0 or (n & (n - 1)) != 0:
        raise ValueError('n must be a power of two')
    bits = int(np.log2(n))
    idx = np.arange(n, dtype=np.uint32)
    rev = np.zeros(n, dtype=np.uint32)
    for i in range(bits):
        rev = (rev << 1) | ((idx >> i) & 1)
    return rev.astype(np.int64)


def r_bitrev64(inp_reordered: np.ndarray) -> np.ndarray:
    """Behavioral model for bitRev64.

    Input is expected in bit-reordered domain (as per kernel API). The model:
      1) maps to linear order using bitrev indices
      2) applies a DC-centered 32-sample circular shift
    """
    x = np.asarray(inp_reordered, dtype=np.complex128).reshape(-1)
    if len(x) != 64:
        raise ValueError(f'r_bitrev64 expects 64 complex inputs, got {len(x)}')

    br = bitrev_indices(64)
    x_linear = x[br]
    return np.concatenate([x_linear[32:], x_linear[:32]])
