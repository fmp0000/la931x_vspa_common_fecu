---
kernel: matrix
precision: [half_fixed, half_float]
status: python_model_wip

inputs:
  - name: vec_p
    shape: [dim1, dim2]
    dtype: complex_hfl        # chfl variant; or complex_hfx for chfx variant
    alignment_words: 32       # vector aligned
    description: "Batch of dim1 input vectors, each of length dim2"
  - name: mat_p
    shape: [dim1, dim3, dim2]
    dtype: complex_sfl        # matrices always in single-precision (csp)
    alignment_words: 32
    description: "Batch of dim1 matrices, each dim3×dim2. For i4 variants: dim1/4 matrices, each reused 4×"

outputs:
  - name: out_p
    shape: [dim1, dim3]
    dtype: complex_hfl        # output is always half-float (chfl)
    alignment_words: 32
    description: "Batch of dim1 output vectors, each of length dim3"

scratch: []

parameters:
  dim1:
    description: "Batch size (number of input/output vectors). Restriction depends on variant."
    valid_values: []
    default: 64
  dim2:
    description: "Input vector length (number of samples per vector)"
    valid_values: []
    default: 2
  dim3:
    description: "Output vector length (number of samples, D3 >= 1)"
    valid_values: []
    default: null
  variant:
    description: "Assembly function variant — encodes (D1 restriction, vec precision, interpolation)"
    valid_values:
      - mat_bmult_64xd2xd3_chfl_csp_chfl    # D1=64, hfl input
      - mat_bmult_d1x2xd3_chfl_csp_chfl     # D1 multiple of 32, D2=2
      - mat_bmult_d1x1xd3_chfl_csp_chfl     # D1 multiple of 32, D2=1
      - mat_bmult_64xd2xd3_chfx_csp_chfl    # D1=64, hfx input
      - mat_bmult_d1x2xd3_chfx_csp_chfl
      - mat_bmult_d1x1xd3_chfx_csp_chfl
      - mat_bmult_i4_256xd2xd3_chfl_csp_chfl  # interpolation order 4, D1=256
      - mat_bmult_i4_d1x2xd3_chfl_csp_chfl
      - mat_bmult_i4_d1x1xd3_chfl_csp_chfl
      - mat_bmult_i4_256xd2xd3_chfx_csp_chfl
      - mat_bmult_i4_d1x2xd3_chfx_csp_chfl
      - mat_bmult_i4_d1x1xd3_chfx_csp_chfl
    default: mat_bmult_64xd2xd3_chfl_csp_chfl

matlab_source:  nxp/matrix/matlab/
c_source:
  - nxp/matrix/src/
python_model:   framework/vspa_model/matrix.py::r_mat_bmult
test_dir:       tests/matrix/
doc:
  - nxp/matrix/doc/Matrix_Implementation_Plan.docx
  - nxp/matrix/doc/Matrix_Testplan.xlsx

depends_on: []

test_cases:
  - id: TC000
    params: {dim1: 64,  dim2: null, dim3: null, prec: half_fixed,  comment: "General purpose"}
    notes: "From testplan xlsx row 0"
  - id: TC001
    params: {prec: half_fixed, comment: ".11ax TX Spatial Mapping"}
    notes: ""
  - id: TC002
    params: {prec: half_fixed, comment: "Matrix interpolation"}
    notes: ""
  - id: TC003
    params: {prec: half_fixed, comment: ".11ac TX Spatial Mapping"}
    notes: ""
  - id: TC004
    params: {prec: half_fixed, comment: ".11ac RX Equalization"}
    notes: ""
  - id: TC005
    params: {prec: half_fixed, comment: ".11ax RX Equalization"}
    notes: ""

perf:
  target_efficiency: null
  cycles: 10142
  au_config: vspa2_16au
  notes: "matrix test harness PASS; re-measured runsim 2026-05-27 (median of 3)"
---

# matrix — Batched Complex Matrix × Vector Multiplication

> Batch multiplication of complex matrices and vectors for RX equalization
> and TX spatial mapping in 5G NR / Wi-Fi PHY pipelines.

## Algorithm

Computes `out[b] = mat[b] × vec[b]` for each element in a batch of size `dim1`.

The `i4` (interpolation order 4) variants reuse each matrix for 4 consecutive
vector multiplications — `dim1/4` unique matrices are applied to `dim1` vectors.
This models interpolation of precoding matrices across 4 subcarriers.

All inputs are kept vector-aligned in DMEM; the VSPA assembly fully pipelines
the inner product accumulation across the AU lanes.

## Function API (Assembly)

```c
// Standard batch (D1=64, arbitrary D2)
void mat_bmult_64xd2xd3_chfl_csp_chfl_asm(
    cfloat16_t  *vec_p,   // input vectors  [D1 × D2], vector aligned
    cfloat32_t  *mat_p,   // input matrices [D1 × D3 × D2], vector aligned
    cfloat16_t  *out_p,   // output vectors [D1 × D3], vector aligned
    uint32_t     dim2,
    uint32_t     dim3);

// Variable D1, D2=2
void mat_bmult_d1x2xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p,
    cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// Variable D1, D2=1
void mat_bmult_d1x1xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p,
    cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// i4 interpolation variants: mat_p holds dim1/4 matrices
void mat_bmult_i4_256xd2xd3_chfl_csp_chfl_asm(...);  // D1=256
void mat_bmult_i4_d1x2xd3_chfl_csp_chfl_asm(...);
void mat_bmult_i4_d1x1xd3_chfl_csp_chfl_asm(...);

// chfx (half-fixed) input variants exist for all of the above
```

## Memory Requirements

All three buffers (vec_p, mat_p, out_p) must be **vector aligned** (32 words).

| Variant suffix | D1 restriction      | D2 restriction | D3       |
|----------------|--------------------|--------------:|---------|
| `64xd2xd3`     | D1 = 64            | D2 ≥ 3        | ≥ 1     |
| `d1x2xd3`      | D1 multiple of 32  | D2 = 2        | ≥ 1     |
| `d1x1xd3`      | D1 multiple of 32  | D2 = 1        | ≥ 1     |
| `i4_256xd2xd3` | D1 = 256           | D2 ≥ 3        | ≥ 1     |
| `i4_d1x2xd3`   | D1 multiple of 32  | D2 = 2        | ≥ 1     |
| `i4_d1x1xd3`   | D1 multiple of 32  | D2 = 1        | ≥ 1     |

## Input/Output Layout

| Port  | Shape             | Type        | Notes                                       |
|-------|-------------------|-------------|---------------------------------------------|
| vec_p | [dim1, dim2]      | complex_hfl | batch of input vectors; or complex_hfx      |
| mat_p | [dim1, dim3, dim2]| complex_sfl | always single-precision; dim1/4 for i4 variants |
| out_p | [dim1, dim3]      | complex_hfl | batch of output vectors                     |

## Precision Modes

| Input vec | Input mat | Output | Variant suffix |
|-----------|-----------|--------|----------------|
| `chfl`    | `csp`     | `chfl` | `_chfl_csp_chfl` |
| `chfx`    | `csp`     | `chfl` | `_chfx_csp_chfl` |

## Test Cases

From `Matrix_Testplan.xlsx`:

| ID    | Use case                    | Notes                       |
|-------|-----------------------------|-----------------------------|
| TC000 | General purpose             | dim1=64                     |
| TC001 | .11ax TX Spatial Mapping    |                             |
| TC002 | Matrix interpolation        | i4 variant                  |
| TC003 | .11ac TX Spatial Mapping    |                             |
| TC004 | .11ac RX Equalization       |                             |
| TC005 | .11ax RX Equalization       |                             |

## Known Constraints

- Matrices (`mat_p`) are always single-precision (csp) regardless of input vector precision.
- The `i4` variants divide the matrix batch size by 4: `dim1/4` unique matrices for `dim1` vectors.
- No in-place operation.
- Investigation (2026-04-19): matrix assembly is ISA-compatible on `vspa2_16au`.
- The previously observed failure was build-environment related:
  - missing include path for `vspa.h` (`submodules/la931x_vspa_common/vspa-sdk/inc`)
  - direct single-file `compile` flow links startup and expects `_main`, which assembly-only objects do not provide.
- Action: use object-level compile for matrix `.sx` sources with SDK include path, and link via a dedicated matrix C harness.

## References

- Implementation plan: `nxp/matrix/doc/Matrix_Implementation_Plan.docx`
- Testplan: `nxp/matrix/doc/Matrix_Testplan.xlsx`
- MATLAB oracle: `nxp/matrix/matlab/`
