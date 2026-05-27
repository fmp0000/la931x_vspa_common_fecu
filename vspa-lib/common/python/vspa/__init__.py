"""Shared VSPA Python primitives mirrored to the submodule layout."""

from .arith import (
    r_single,
    r_half,
    r_half_flt,
    r_convert,
    r_smad,
    r_smac,
    _f64_to_f32_trunc,
    _f32_to_f16_trunc,
    _f32_add_trunc,
)
from .io import (
    _sm16_to_float,
    _float_to_sm16,
    read_binary,
    read_complex_binary,
    read_ctrl,
    PREC_IDX,
)

__all__ = [
    'r_single', 'r_half', 'r_half_flt', 'r_convert', 'r_smad', 'r_smac',
    '_f64_to_f32_trunc', '_f32_to_f16_trunc', '_f32_add_trunc',
    '_sm16_to_float', '_float_to_sm16',
    'read_binary', 'read_complex_binary', 'read_ctrl', 'PREC_IDX',
]