# SPDX-License-Identifier: BSD-3-Clause
"""Shared precision codecs for test-vector generation."""

import numpy as np

Q15_SCALE = np.float64(32767.0)


def float_to_q15(x: np.ndarray) -> np.ndarray:
    """Encode float64 to Q15 two's-complement int16."""
    x = np.asarray(x, dtype=np.float64)
    scaled = np.round(x * Q15_SCALE).astype(np.int64)
    return np.clip(scaled, -32768, 32767).astype(np.int16)


def q15_to_float(v: np.ndarray) -> np.ndarray:
    """Decode Q15 two's-complement int16 to float64."""
    return np.asarray(v, dtype=np.int16).astype(np.float64) / Q15_SCALE