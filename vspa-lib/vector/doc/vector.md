---
kernel: vector
precision: [half_fixed, half, single]
status: sim_verified

inputs:
  - name: px
    shape: [L*32]             # L DMEM lines, each line = 32 half-words
    dtype: complex_hfx
    alignment_words: 32       # vector-aligned (1 DMEM line)
    description: "Input vector (vmult: FFT output; rcpv: channel estimate h)"
  - name: px2
    shape: [L*32]
    dtype: complex_sfl
    alignment_words: 32
    description: "Second input for vmult: equalizer weights (rcpv output = 1/h)"

outputs:
  - name: py
    shape: [L*32]
    dtype: complex_hfl        # vmult output: complex_hfl; rcpv output: complex_sfl
    alignment_words: 32
    description: "Output vector"

scratch: []

parameters:
  L:
    description: "Number of DMEM lines (each = 32 complex half-fixed samples)"
    valid_values: [1, 2, 3, 4, 8, 15, 31]
    default: 4
  sub_kernel:
    description: "Sub-kernel selection"
    valid_values: [vmult, rcpv, dot_prod, vAddSclr, vMultiSclr, mat_by_vec]
    default: vmult

matlab_source:  nxp/vector/matlab/
c_source:       []
python_model:   framework/vspa_model/vector.py::r_vector_dot_complex
test_dir:       tests/vector/
doc:
  - nxp/vector/doc/vector_rcpv_vmult_IP.docx
  - nxp/vector/doc/Dot_Prod_Implementation_Plan.docx
  - nxp/vector/doc/vector_vSclr_IP.docx
  - nxp/vector/doc/mat_by_vec_implementation_plan.docx

depends_on: []

test_cases:
  # vmult tests: L ∈ {1,2,3,4,8,15,31}
  - id: TC_vmult_L1
    params: {sub_kernel: vmult, L: 1}
    notes: "Minimum L"
  - id: TC_vmult_L8
    params: {sub_kernel: vmult, L: 8}
    notes: "Typical 802.11n 20MHz"
  - id: TC_vmult_L31
    params: {sub_kernel: vmult, L: 31}
    notes: "Maximum 802.11ax 80MHz"
  # rcpv tests: same L set
  - id: TC_rcpv_L2
    params: {sub_kernel: rcpv, L: 2}
    notes: "802.11n 20MHz cHalf"
  - id: TC_rcpv_L31
    params: {sub_kernel: rcpv, L: 31}
    notes: "802.11ax 80MHz"
  # dot_prod: circular and linear
  - id: TC_dot_circ_L1
    params: {sub_kernel: dot_prod, variant: circular, num_lines: 1}
    notes: ""
  # mat_by_vec
  - id: TC_mat_by_vec_L2M4
    params: {sub_kernel: mat_by_vec, L: 2, M: 4}
    notes: ""

perf:
  target_efficiency: null
  cycles: 6020
  au_config: vspa2_16au
  notes: "PASS vspa2_16au using rhf_rhf_rhf_vAddSclr_asm (L=2) harness; re-measured runsim 2026-05-27 (median of 3)"
---

# vector — General Linear Algebra: vmult, rcpv, dot_prod, vSclr, mat_by_vec

> Collection of general-purpose vector operations used throughout the WiFi PHY
> pipeline: equalization (`vmult`, `rcpv`), dot products, scalar ops, and matrix-vector products.

## Sub-kernels

### 1. `vmult` — Element-wise Complex Vector Multiply

Used for SISO channel equalization: `y = x1 .* x2` (element-wise).

```c
void chp_chf_csp_vmult_asm(vspa2_complex_float16 *py,
                            vspa2_complex_fixed16 *px1,
                            vspa_complex_float32  *px2,
                            size_t L);
```

| Buffer | Min size (words) | Alignment (words) | Dtype        |
|--------|-----------------|-------------------|--------------|
| y      | 32              | 32                | complex_hfl  |
| x1     | 32              | 32                | complex_hfx  |
| x2     | 32              | 32                | complex_sfl  |

- `L` = number of DMEM lines (1 line = 32 half-fixed complex = 64 half-words)
- Loop: 4 cycles per input line (3 loads, 1 store, 2 cmad)

### 2. `rcpv` — Element-wise Complex Reciprocal (SISO equalizer weight design)

Computes `hinv = conj(h) ./ abs(h).^2`:

```c
void csp_chf_rcpv_asm(vspa_complex_float32 *py,
                      vspa2_complex_fixed16 *px,
                      size_t L);
void csp_csp_rcpv_asm(vspa_complex_float32 *py,
                      vspa_complex_float32  *px,
                      size_t L);
```

| Buffer | Min size (words) | Alignment (words) | Dtype        |
|--------|-----------------|-------------------|--------------|
| y      | 32              | 32                | complex_sfl  |
| x      | 32              | 32                | complex_hfx  |

- Loop: 4 cycles per input line (merged 3-stage pipeline; 1 load, 2 stores)
- Supports any `L >= 1`

### 3. `dot_prod` — Complex Dot Product with Circular Buffer Support

```c
void dot_prod_circ_x32chf_csp_asm(
    vspa_complex_float32 *out_p,
    vspa2_complex_fixed16 *inp_circ_p,   // vector-aligned, circular buf
    vspa2_complex_fixed16 *inp2_p,       // NOT vector-aligned
    uint32_t num_lines);                 // each line = 32 complex samples

void dot_prod_line_x32chf_csp_asm(
    vspa_complex_float32 *out_p,
    vspa2_complex_fixed16 *inp1_p,       // NOT vector-aligned
    vspa2_complex_fixed16 *inp2_p,
    uint32_t num_lines);
```

- `inp_circ_p` must be vector-aligned; `inp1_p`/`inp2_p` may be non-aligned.
- Output: single complex scalar (complex_sfl).

### 4. `vSclr` — Vector Scalar Arithmetic (vAddSclr / vMultiSclr)

Inline families for element-wise add/multiply with a scalar:

```c
// Add scalar alpha to each element
static inline void vAddSclr(T_out *py, T_in *px, T_scalar alpha, size_t L);
// Multiply each element by scalar
static inline void vMultiSclr(T_out *py, T_in *px, T_scalar alpha, size_t L);
```

Supported type combinations: 6 variants (hfx, hfl, sfl combinations).
All buffers must be vector-aligned.

### 5. `mat_by_vec` — Matrix-Vector Multiply

Computes `y = X * a` where X is K×M, a is M×1:

```c
void mat_by_vec_chfx_chfx_chfx(vspa_complex_fixed16 *py,
                                 vspa_complex_fixed16 const *px,
                                 vspa_complex_fixed16 const *pa,
                                 uint32_t offset, uint32_t L, uint32_t M);
// ... 10 total variants (output: chfx/chfl; matrix dtype: chfx/chfl/rhfx/rhfl/rfl)
```

Parameters:
- `py`, `px`: DMEM-aligned (64 half-words)
- `pa`: 2 half-words minimum alignment
- `offset`: row stride in words — must be integer multiple of 32 (one DMEM line)
- `L = ceil(K/32)`: number of DMEM lines for output (K = rows of X)
- `M`: number of entries in input vector `a` (columns of X)

| Buffer | Min size (half-words) | Alignment (half-words) |
|--------|-----------------------|------------------------|
| py     | L×64                  | 64                     |
| px     | L×64                  | 64                     |
| pa     | M×2                   | 2                      |

Available output×matrix variants:
- `chfx_chfx_chfx`, `chfx_chfx_chfl`, `chfx_chfx_rhfx`, `chfx_chfx_rhfl`, `chfx_chfx_rfl`
- `chfl_chfx_chfx`, `chfl_chfx_chfl`, `chfl_chfx_rhfx`, `chfl_chfx_rhfl`, `chfl_chfx_rfl`

## Test Plan

From `vector_rcpv_vmult_IP.docx` — L values for 802.11 standards:

| Standard | ChannelBW | nLines_cHP | nLines_cSP |
|----------|-----------|------------|------------|
| 11a/n/ac | 20 MHz    | 2          | 3          |
| 11ax     | 20 MHz    | 8          | 15         |
| 11ax     | 80 MHz    | 31         | 62         |

Test L set: `{1, 2, 3, 4, 8, 15, 31}`

## References

- `nxp/vector/doc/vector_rcpv_vmult_IP.docx`
- `nxp/vector/doc/Dot_Prod_Implementation_Plan.docx`
- `nxp/vector/doc/vector_vSclr_IP.docx`
- `nxp/vector/doc/mat_by_vec_implementation_plan.docx`
- NXP vspa-lib: `submodules/la931x_vspa_common/vspa-lib/vector/`
