#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for phase_ramp_gen using local python/model.py."""

from __future__ import annotations

import struct
from pathlib import Path
import sys

import numpy as np

_TESTS_DIR = Path(__file__).resolve().parent
_KERNEL_DIR = _TESTS_DIR.parent
_COMMON_PY = _KERNEL_DIR.parent / 'common' / 'python'

for p in (str(_COMMON_PY), str(_KERNEL_DIR / 'python')):
    if p not in sys.path:
        sys.path.insert(0, p)

from model import r_phase_ramp_gen
from utils.hex_io import write_hex_u16

OUTDIR = _TESTS_DIR / 'vectors'
NUM_LINES = 2
SAMP_PER_LINE = 32
N_CPLX = NUM_LINES * SAMP_PER_LINE
NORM_FREQ = 0.0102
INITIAL_PHASE = -122
GAIN = 1.0 + 0.0j

PHASE_RAMP = int(np.round(NORM_FREQ * (2 ** 32)))
PHASE_INIT_I32 = np.int32(INITIAL_PHASE)
PHASE_INIT = int(np.uint32(PHASE_INIT_I32.view(np.uint32)))


def half_to_u16(c):
    re = np.asarray(c).real.astype(np.float16)
    im = np.asarray(c).imag.astype(np.float16)
    re_u = np.frombuffer(re.tobytes(), dtype=np.uint16)
    im_u = np.frombuffer(im.tobytes(), dtype=np.uint16)
    out = np.empty(2 * re_u.size, dtype=np.uint16)
    out[0::2] = re_u
    out[1::2] = im_u
    return out


def main() -> None:
    out = r_phase_ramp_gen(GAIN, PHASE_RAMP, PHASE_INIT, NUM_LINES)

    g_re_u32 = struct.unpack('<I', struct.pack('<f', float(np.real(GAIN))))[0]
    g_im_u32 = struct.unpack('<I', struct.pack('<f', float(np.imag(GAIN))))[0]
    gain_hw = np.array([
        g_re_u32 & 0xFFFF,
        (g_re_u32 >> 16) & 0xFFFF,
        g_im_u32 & 0xFFFF,
        (g_im_u32 >> 16) & 0xFFFF,
    ], dtype=np.uint16)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u16(gain_hw, str(OUTDIR / 'input.hex'))
    write_hex_u16(half_to_u16(out), str(OUTDIR / 'ref.hex'))

    print(f'Generated nco_phase_ramp vectors: lines={NUM_LINES}, N={N_CPLX}')


if __name__ == '__main__':
    main()
