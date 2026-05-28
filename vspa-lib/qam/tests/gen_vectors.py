#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""QAM modulator vector generator using local python/model.py."""

from __future__ import annotations

import os
from pathlib import Path
import sys

import numpy as np

_TESTS_DIR = Path(__file__).resolve().parent
_KERNEL_DIR = _TESTS_DIR.parent
_COMMON_PY = _KERNEL_DIR.parent / 'common' / 'python'

for p in (str(_COMMON_PY), str(_KERNEL_DIR / 'python')):
    if p not in sys.path:
        sys.path.insert(0, p)

from model import QAM_MODES, r_qam_mod
from utils.hex_io import write_hex_u32

TOKEN_TO_MODE = {
    'BPSK': 'bpsk',
    'QPSK': 'qpsk',
    '16QAM': '16qam',
    '64QAM': '64qam',
    '256QAM': '256qam',
    '1024QAM': '1024qam',
}

N_LINES_PER_MODE = {
    'BPSK': 32,
    'QPSK': 16,
    '16QAM': 8,
    '64QAM': 32,
    '256QAM': 4,
    '1024QAM': 32,
}

OUTDIR = _TESTS_DIR / 'vectors'


def main() -> None:
    token = os.environ.get('QAM_MODE', 'BPSK').upper()
    if token not in TOKEN_TO_MODE:
        raise SystemExit(f'unknown QAM_MODE={token!r}, expected one of {sorted(TOKEN_TO_MODE)}')

    mode = TOKEN_TO_MODE[token]
    m_bits = QAM_MODES[mode]['M']
    n_lines = N_LINES_PER_MODE[token]
    n_symbols = n_lines * 32
    n_input_words = (n_symbols * m_bits) // 32

    seed = 20251020 + sum(ord(c) for c in token)
    rng = np.random.default_rng(seed=seed)
    bits_u32 = rng.integers(0, 1 << 32, size=n_input_words, dtype=np.uint64).astype(np.uint32)

    ref_u32 = r_qam_mod(bits_u32, mode)
    if ref_u32.size != n_symbols:
        raise SystemExit(f'oracle size mismatch: got {ref_u32.size}, expected {n_symbols}')

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(bits_u32, str(OUTDIR / 'input.hex'))
    write_hex_u32(ref_u32, str(OUTDIR / 'ref.hex'))

    print(f'Generated qam vectors: mode={token} N={n_lines} (input_words={n_input_words}, ref_symbols={n_symbols})')


if __name__ == '__main__':
    main()
