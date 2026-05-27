# SPDX-License-Identifier: BSD-3-Clause
"""Shared packing helpers for Q15 and SM16 complex vector layouts."""

import numpy as np

from .precision import float_to_q15, q15_to_float
from vspa.io import _float_to_sm16, _sm16_to_float


def complex_to_u32_q15(c: np.ndarray) -> np.ndarray:
    """Pack complex float array to uint32 Q15: (Im_i16 << 16) | Re_i16."""
    c = np.asarray(c)
    re = float_to_q15(c.real).astype(np.uint32) & 0xFFFF
    im = float_to_q15(c.imag).astype(np.uint32) & 0xFFFF
    return (im << 16) | re


def u32_to_complex_q15(u32: np.ndarray) -> np.ndarray:
    """Unpack uint32 Q15 to complex float64."""
    u32 = np.asarray(u32, dtype=np.uint32)
    re_i16 = (u32 & 0xFFFF).astype(np.uint16).view(np.int16)
    im_i16 = (u32 >> 16).astype(np.uint16).view(np.int16)
    return q15_to_float(re_i16) + 1j * q15_to_float(im_i16)


def complex_to_u32_sm16(c: np.ndarray) -> np.ndarray:
    """Pack complex float array to uint32 SM16: (Im_sm16 << 16) | Re_sm16."""
    c = np.asarray(c)
    re = _float_to_sm16(c.real).astype(np.uint32)
    im = _float_to_sm16(c.imag).astype(np.uint32)
    return (im << 16) | re


def u32_to_complex_sm16(u32: np.ndarray) -> np.ndarray:
    """Unpack uint32 SM16 to complex float64."""
    u32 = np.asarray(u32, dtype=np.uint32)
    re = _sm16_to_float((u32 & 0xFFFF).astype(np.uint16))
    im = _sm16_to_float((u32 >> 16).astype(np.uint16))
    return re + 1j * im