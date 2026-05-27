# SPDX-License-Identifier: BSD-3-Clause
"""Binary and sign-magnitude I/O helpers mirrored under the submodule layout."""

import numpy as np


def _sm16_to_float(u16: np.ndarray) -> np.ndarray:
    """Decode VSPA sign-magnitude uint16 to float64."""
    u16 = np.asarray(u16, dtype=np.uint16)
    sign = (u16 >> 15).astype(np.float64)
    mag = (u16 & 0x7FFF).astype(np.float64)
    return np.where(sign == 0, mag, -mag) / 32768.0


def _float_to_sm16(x: np.ndarray) -> np.ndarray:
    """Encode float64 to VSPA sign-magnitude uint16 using truncation."""
    hf16_max = 1.0 - 2.0 ** -15
    x = np.clip(np.asarray(x, dtype=np.float64), -hf16_max, hf16_max)
    mag = np.floor(np.abs(x) * 32768).astype(np.uint16) & 0x7FFF
    sign = np.signbit(x).astype(np.uint16) << 15
    return (sign | mag).astype(np.uint16)


def read_binary(path: str, prec: str) -> np.ndarray:
    """Read NXP binary test vector file into float64 array."""
    raw = open(path, 'rb').read()
    if prec == 'half_fixed':
        return _sm16_to_float(np.frombuffer(raw, dtype='<u2'))
    if prec == 'half':
        return np.frombuffer(raw, dtype='<f2').astype(np.float64)
    if prec == 'single':
        return np.frombuffer(raw, dtype='<f4').astype(np.float64)
    if prec == 'uint':
        return np.frombuffer(raw, dtype='<u4').astype(np.float64)
    raise ValueError(f'Unknown prec: {prec}')


def read_complex_binary(path: str, prec: str) -> np.ndarray:
    """Read interleaved complex data from NXP binary file."""
    flat = read_binary(path, prec)
    return flat[0::2] + 1j * flat[1::2]


PREC_IDX = {0: 'half_fixed', 1: 'half', 2: 'single'}


def read_ctrl(path: str):
    """Read ctrl.bin to (inputLen, inp_prec_str, out_prec_str)."""
    ctrl = np.frombuffer(open(path, 'rb').read(), dtype='<u4')
    return int(ctrl[0]), PREC_IDX[int(ctrl[1])], PREC_IDX[int(ctrl[2])]