#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""
Generate C-includable test vectors for the decimator_2x_32hf asm kernel.

Mirrors the NXP cwproj testbench layout:
  - First-block call: inp_hist = zeros (BSS-zeroed wrap-around region).
  - DECIM_FLT_LEN configurable; default 32.
  - Verified bit-exact for FLT_LEN in {16, 18, 20, 22, 24, 26, 28, 30, 32}.

Output (tests/vectors/):
  input.hex  — 2*INP_LEN  halfwords (interleaved SM16 re, im, re, im, …)
  ref.hex    — 2*OUT_LEN  halfwords (interleaved SM16)
"""

from __future__ import annotations

# ── path bootstrap (must run before any local imports) ──────────────────────
import sys
from pathlib import Path

_TESTS_DIR  = Path(__file__).resolve().parent
_KERNEL_DIR = _TESTS_DIR.parent
_COMMON_PY  = _KERNEL_DIR.parent / 'common' / 'python'

for _p in (str(_COMMON_PY), str(_KERNEL_DIR / 'python')):
    if _p not in sys.path:
        sys.path.insert(0, _p)
# ────────────────────────────────────────────────────────────────────────────

import argparse
import re

import numpy as np

from vspa.io import _float_to_sm16
from utils.hex_io import write_hex_u16
from model import r_decimator_2x

OUTDIR        = _TESTS_DIR / 'vectors'
DECIM_FACT    = 2
OUT_LEN       = 32                         # complex outputs per asm call
INP_LEN       = OUT_LEN * DECIM_FACT       # 64 complex inputs
DECIM_FLT_LEN = 32                         # default (matches Makefile -DTEST_DECIM_FLT_LEN)


def load_taps(flt_len: int) -> np.ndarray:
    """Load float32 tap coefficients for the requested FLT_LEN from the NXP source."""
    tap_file = _KERNEL_DIR / 'src' / 'decimator_filter.txt'
    txt = tap_file.read_text()
    pat = re.compile(
        r'#if DECIM_FLT_LEN == (\d+)\s+//[^\n]*\n([0-9A-Fxa-f, \n]+?)\s*#endif',
        re.S,
    )
    for m in pat.finditer(txt):
        if int(m.group(1)) == flt_len:
            words = re.findall(r'0x[0-9A-Fa-f]+', m.group(2))
            u32 = np.array([int(w, 16) for w in words], dtype=np.uint32)
            return u32.view('<f4').astype(np.float64)
    raise RuntimeError(f'No taps found for DECIM_FLT_LEN={flt_len} in {tap_file}')


def interleave_sm16(c: np.ndarray) -> np.ndarray:
    """Interleave complex array to uint16 SM16: re[0], im[0], re[1], im[1], …"""
    c = np.asarray(c)
    out = np.empty(2 * len(c), dtype=np.uint16)
    out[0::2] = _float_to_sm16(c.real)
    out[1::2] = _float_to_sm16(c.imag)
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--seed', type=int, default=42, help='RNG seed (default: 42)')
    parser.add_argument('--flt-len', type=int, default=DECIM_FLT_LEN,
                        help=f'Filter length (default: {DECIM_FLT_LEN})')
    args = parser.parse_args()

    rng  = np.random.default_rng(args.seed)
    x    = rng.uniform(-0.7, 0.7, INP_LEN) + 1j * rng.uniform(-0.7, 0.7, INP_LEN)
    taps = load_taps(args.flt_len)

    # First-block: history is all zeros (matches BSS-zeroed cwproj buffer).
    y_full, _ = r_decimator_2x(
        x, taps,
        inp_hist=np.zeros(args.flt_len - 1, dtype=np.complex128),
        input_prec='half_fixed',
        filter_prec='single',
        output_prec='half_fixed',
    )
    y_out = y_full[:OUT_LEN]

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u16(interleave_sm16(x),     str(OUTDIR / 'input.hex'))
    write_hex_u16(interleave_sm16(y_out), str(OUTDIR / 'ref.hex'))

    print(f'Generated decimator vectors (FLT_LEN={args.flt_len}, seed={args.seed}):')
    print(f'  input.hex : {INP_LEN} complex → {2 * INP_LEN} SM16 halfwords')
    print(f'  ref.hex   : {OUT_LEN} complex → {2 * OUT_LEN} SM16 halfwords')


if __name__ == '__main__':
    main()
