#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for log_asm using local python/model.py."""

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

from model import LOG_FACT_VALUES, r_log
from utils.hex_io import write_hex_u32

OUTDIR = _TESTS_DIR / 'vectors'
N = 32
FACT_NAME = os.environ.get('LOG_FACT', 'LOG2x1')


def main() -> None:
    if FACT_NAME not in LOG_FACT_VALUES:
        raise SystemExit(f'unknown LOG_FACT={FACT_NAME!r}, expected one of {sorted(LOG_FACT_VALUES)}')
    fact_f32 = LOG_FACT_VALUES[FACT_NAME]

    rng = np.random.default_rng(seed=20251020)
    m_bits = 5
    js = rng.integers(0, 2 ** m_bits, size=N)
    ks = rng.integers(-10, 11, size=N)
    x = ((1.0 + js / (2.0 ** m_bits)) * (2.0 ** ks.astype(np.float64))).astype(np.float32)

    y = r_log(x, fact_f32)

    x_u32 = np.frombuffer(x.tobytes(), dtype='<u4')
    y_u32 = np.frombuffer(y.tobytes(), dtype='<u4')

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u32(x_u32, str(OUTDIR / 'input.hex'))
    write_hex_u32(y_u32, str(OUTDIR / 'ref.hex'))

    print(f'Generated logarithm vectors: N={N}, factor={FACT_NAME} (= {fact_f32})')


if __name__ == '__main__':
    main()
