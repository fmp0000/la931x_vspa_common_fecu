#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate matrix vectors using local python/model.py (TC043-style config)."""

from __future__ import annotations

from pathlib import Path
import sys

import numpy as np

_TESTS_DIR = Path(__file__).resolve().parent
_KERNEL_DIR = _TESTS_DIR.parent
_COMMON_PY = _KERNEL_DIR.parent / 'common' / 'python'

for p in (str(_COMMON_PY), str(_KERNEL_DIR / 'python')):
    if p not in sys.path:
        sys.path.insert(0, p)

from model import r_mat_bmult
from utils.hex_io import write_hex_u32
from vspa.arith import _f32_to_f16_trunc
from vspa.io import _float_to_sm16

DIM1 = 64
DIM2 = 1
DIM3 = 1
MAT_INTERP = 1

VEC_PREC = 'half_fixed'
MAT_PREC = 'single'
OUT_PREC = 'half'

OUTDIR = _TESTS_DIR / 'vectors'


def pack_complex_sm16(c):
    re = _float_to_sm16(np.asarray(c).real).astype(np.uint32)
    im = _float_to_sm16(np.asarray(c).imag).astype(np.uint32)
    return (im << 16) | re


def pack_complex_single(c):
    c = np.asarray(c)
    re_f32 = c.real.astype(np.float32)
    im_f32 = c.imag.astype(np.float32)
    re_u32 = np.frombuffer(re_f32.tobytes(), dtype='<u4')
    im_u32 = np.frombuffer(im_f32.tobytes(), dtype='<u4')
    out = np.empty(2 * len(re_u32), dtype=np.uint32)
    out[0::2] = re_u32
    out[1::2] = im_u32
    return out


def pack_complex_half_trunc(c):
    c = np.asarray(c)
    re_f16_f64 = _f32_to_f16_trunc(c.real.astype(np.float32))
    im_f16_f64 = _f32_to_f16_trunc(c.imag.astype(np.float32))
    re_u16 = np.frombuffer(re_f16_f64.astype(np.float16).tobytes(), dtype=np.uint16).astype(np.uint32)
    im_u16 = np.frombuffer(im_f16_f64.astype(np.float16).tobytes(), dtype=np.uint16).astype(np.uint32)
    return (im_u16 << 16) | re_u16


def main() -> None:
    rng = np.random.default_rng(42)

    vec_flat = rng.uniform(-0.7, 0.7, DIM1 * DIM2) + 1j * rng.uniform(-0.7, 0.7, DIM1 * DIM2)
    vec = vec_flat.reshape(DIM1, DIM2, order='F')

    mat_dim1 = DIM1 // MAT_INTERP
    mat_flat = rng.uniform(-1.0, 1.0, mat_dim1 * DIM3 * DIM2) + 1j * rng.uniform(-1.0, 1.0, mat_dim1 * DIM3 * DIM2)
    mat = mat_flat.reshape((mat_dim1, DIM3, DIM2), order='F')

    out = r_mat_bmult(vec, mat, VEC_PREC, MAT_PREC, OUT_PREC, MAT_INTERP)

    vec_disk = vec.flatten(order='F')
    mat_disk = mat.flatten(order='F')
    out_disk = out.flatten(order='F')

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(pack_complex_sm16(vec_disk), str(OUTDIR / 'vec.hex'))
    write_hex_u32(pack_complex_single(mat_disk), str(OUTDIR / 'mat.hex'))
    write_hex_u32(pack_complex_half_trunc(out_disk), str(OUTDIR / 'ref.hex'))

    print(f'Generated matrix vectors: D1={DIM1} D2={DIM2} D3={DIM3} mi={MAT_INTERP}')


if __name__ == '__main__':
    main()
