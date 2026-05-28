#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
"""Generate vectors for comp16_12b using positive half_fixed inputs."""

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

from model import comp16_12b_model
from utils.hex_io import write_hex_u16, write_hex_u32
from vspa.io import _float_to_sm16

NB = 2
SEED = 42
OUTDIR = _TESTS_DIR / 'vectors'


def main() -> None:
    rng = np.random.default_rng(SEED)

    # Positive-only input avoids sign-magnitude vs two's-complement ambiguity.
    x = rng.uniform(0.0, 0.95, size=NB * 24 * 64).astype(np.float64)
    inp_u16 = _float_to_sm16(x).astype(np.uint16)
    ref_u16 = comp16_12b_model(inp_u16, NB)

    OUTDIR.mkdir(parents=True, exist_ok=True)
    write_hex_u16(inp_u16, str(OUTDIR / 'input.hex'))
    write_hex_u16(ref_u16, str(OUTDIR / 'ref.hex'))
    write_hex_u32(np.array([NB], dtype=np.uint32), str(OUTDIR / 'cfg.hex'))

    print(f'Generated compression16_12b vectors: nb={NB}, seed={SEED}')


if __name__ == '__main__':
    main()
