# SPDX-License-Identifier: BSD-3-Clause
"""Python model for comp16_12b kernel."""

from __future__ import annotations

import numpy as np


def sm16_to_twos_u16(u16: np.ndarray) -> np.ndarray:
    u16 = np.asarray(u16, dtype=np.uint16)
    sign = (u16 >> 15) & 1
    mag = (u16 & 0x7FFF).astype(np.int32)
    s32 = np.where(sign != 0, -mag, mag).astype(np.int16)
    return s32.view(np.uint16)


def comp16_12b_model(inp_sm16_u16: np.ndarray, nb: int) -> np.ndarray:
    inp_sm16_u16 = np.asarray(inp_sm16_u16, dtype=np.uint16)
    expected_in = nb * 24 * 64
    if inp_sm16_u16.size != expected_in:
        raise ValueError(f'expected {expected_in} input words, got {inp_sm16_u16.size}')

    inp_blk = sm16_to_twos_u16(inp_sm16_u16).reshape(nb, 24, 64)
    out = np.zeros((nb, 18, 64), dtype=np.uint16)

    out[:, 0:18, :] = inp_blk[:, 0:18, :] & np.uint16(0xFFF0)

    tail = inp_blk[:, 18:24, :]
    out[:, 0::3, :] |= (tail >> 4) & np.uint16(0x000F)
    out[:, 1::3, :] |= (tail >> 8) & np.uint16(0x000F)
    out[:, 2::3, :] |= (tail >> 12) & np.uint16(0x000F)

    return out.reshape(-1)
