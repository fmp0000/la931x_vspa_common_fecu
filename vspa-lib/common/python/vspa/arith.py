# SPDX-License-Identifier: BSD-3-Clause
"""Core VSPA arithmetic primitives mirrored under the submodule layout."""

import numpy as np


def r_single(x):
    """Round to single-precision float, matching VSPA MAD/MAF precision."""
    x = np.asarray(x)
    if np.iscomplexobj(x):
        return (np.asarray(x.real, dtype=np.float32).astype(np.float64) +
                1j * np.asarray(x.imag, dtype=np.float32).astype(np.float64))
    return np.asarray(x, dtype=np.float32).astype(np.float64)


def _q15_truncate(x: np.ndarray) -> np.ndarray:
    """Convert float64 array to Q15 fixed-point using VSPA truncation rules."""
    x = np.asarray(x, dtype=np.float64)
    is_neg = np.signbit(x)
    abs_x = np.where(np.isnan(x), 1.0, np.minimum(np.abs(x), 1.0))
    scaled = abs_x * 32768.0
    int_val = np.floor(scaled).astype(np.int64)
    int_val = np.where(scaled < 0.5, np.int64(0), int_val)
    int_val = np.minimum(int_val, np.int64(0x7FFF))
    result = int_val.astype(np.float64) / 32768.0
    return np.where(is_neg, -result, result)


def r_half(x):
    """Round to Q15 fixed-point (half_fixed), range [-1, 1)."""
    x = np.asarray(x)
    if np.iscomplexobj(x):
        return _q15_truncate(x.real) + 1j * _q15_truncate(x.imag)
    return _q15_truncate(x)


def _f32_to_f16_trunc(f32_arr):
    """Convert float32 to float16 using truncation, matching VSPA hardware."""
    inp = np.asarray(f32_arr)
    shape = inp.shape
    u32 = np.frombuffer(inp.astype(np.float32).ravel().tobytes(), dtype='<u4')
    sign16 = ((u32 >> 16) & 0x8000).astype(np.uint16)
    exp32 = (u32 >> 23) & 0xFF
    mant32 = u32 & 0x7FFFFF

    bits16 = sign16.copy()

    is_nan = (exp32 == 0xFF) & (mant32 != 0)
    is_inf = (exp32 == 0xFF) & (mant32 == 0)
    is_normal = (exp32 >= 113) & (exp32 <= 142)

    if np.any(is_normal):
        exp16 = (exp32[is_normal].astype(np.int32) - 127 + 15).astype(np.uint16)
        mant16 = (mant32[is_normal] >> 13).astype(np.uint16)
        bits16[is_normal] = sign16[is_normal] | (exp16 << 10) | mant16

    bits16[is_inf] = sign16[is_inf] | np.uint16(0x7C00)
    bits16[is_nan] = sign16[is_nan] | np.uint16(0x7E00)

    return np.frombuffer(bits16.tobytes(), dtype=np.float16).astype(np.float64).reshape(shape)


def r_half_flt(x):
    """Round to float16 using VSPA truncation semantics."""
    x = np.asarray(x)
    if np.iscomplexobj(x):
        return _f32_to_f16_trunc(x.real) + 1j * _f32_to_f16_trunc(x.imag)
    return _f32_to_f16_trunc(x)


def r_convert(x, prec):
    """Convert to VSPA precision matching r_convert.m."""
    x = np.asarray(x)
    if prec == 'half_fixed':
        return r_half(x)
    if prec == 'half':
        return r_half_flt(x)
    if prec == 'single':
        return r_single(x)
    if prec == 'double':
        return x.astype(np.complex128 if np.iscomplexobj(x) else np.float64)
    raise ValueError(f'Unknown precision: {prec}')


_F32_MIN_NORMAL = 2.0 ** -126


def _f64_to_f32_trunc(x):
    """Convert float64 to float32 with truncation toward zero."""
    x = np.asarray(x, dtype=np.float64)
    f32 = np.asarray(x, dtype=np.float32)
    away = np.abs(f32.astype(np.float64)) > np.abs(x)
    u32 = np.frombuffer(f32.ravel().tobytes(), dtype='<u4')
    u32_adj = np.where(away.ravel(), u32 - np.uint32(1), u32)
    out = np.frombuffer(u32_adj.astype(np.uint32).tobytes(), dtype='<f4').astype(np.float64).reshape(x.shape)

    abs_out = np.abs(out)
    is_subnormal = (abs_out > 0) & (abs_out < _F32_MIN_NORMAL)
    if np.any(is_subnormal):
        sign = np.signbit(out)
        out = np.where(is_subnormal, np.where(sign, -0.0, 0.0), out)
    return out


def _f32_add_trunc(a, b):
    """Float32 add with truncate-toward-zero rounding."""
    s = np.asarray(a, dtype=np.float64) + np.asarray(b, dtype=np.float64)
    return _f64_to_f32_trunc(s)


def r_smad(A, B, C):
    """Bit-exact VSPA multiply-add: two truncating float32 steps."""
    A = np.asarray(A, dtype=np.float64 if not np.iscomplexobj(A) else np.complex128)
    B = np.asarray(B, dtype=np.float64 if not np.iscomplexobj(B) else np.complex128)
    C = np.asarray(C, dtype=np.float64 if not np.iscomplexobj(C) else np.complex128)

    if np.iscomplexobj(A) or np.iscomplexobj(B) or np.iscomplexobj(C):
        ar = A.real
        ai = A.imag
        br = B.real
        bi = B.imag
        cr = C.real
        ci = C.imag
        t1r = _f64_to_f32_trunc(ar * br)
        t2r = _f64_to_f32_trunc(-ai * bi)
        t3r = _f64_to_f32_trunc(t1r + t2r)
        re = _f64_to_f32_trunc(cr + t3r)
        t1i = _f64_to_f32_trunc(ar * bi)
        t2i = _f64_to_f32_trunc(ai * br)
        t3i = _f64_to_f32_trunc(t1i + t2i)
        im = _f64_to_f32_trunc(ci + t3i)
        return re + 1j * im
    return _f64_to_f32_trunc(C + _f64_to_f32_trunc(A * B))


def r_smac(A, B, C):
    """Sequential truncating float32 multiply-accumulate (VSPA r_smac)."""
    A = np.asarray(A)
    B = np.asarray(B)
    C = np.asarray(C)

    is_complex = np.iscomplexobj(A) or np.iscomplexobj(B) or np.iscomplexobj(C)

    if A.ndim == 1:
        A = A.reshape(-1, 1)
    if B.ndim == 1:
        B = B.reshape(-1, 1)

    _, _ = A.shape
    dtype = np.complex128 if is_complex else np.float64
    result = C.ravel().astype(dtype)

    for k in range(A.shape[0]):
        result = r_smad(A[k], B[k], result)

    return result