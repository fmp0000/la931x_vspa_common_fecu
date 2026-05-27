---
kernel: dft
precision: [half_fixed, single]
status: sim_verified

inputs:
  - name: in_p
    shape: [N]
    dtype: complex_hfx        # hfx for dft_hfx_* variants; sfl for dft_sfl_*
    alignment_words: 64       # 64 half-words = 32 words
    description: "DFT input sequence"

outputs:
  - name: out_p
    shape: [N]
    dtype: complex_hfl        # hfl for *_hfl variants; sfl for *_sfl variants
    alignment_words: 64
    description: "DFT output"

scratch:
  - name: scratch_p
    size_words: "388"         # 388 half-words (194 for hfx/hfl, 388 for sfl)
    alignment_words: 64
    description: "Required only for dft_xx_xx_asm (N>96); not needed for mini_dft"

parameters:
  N:
    description: "DFT input sequence length. dft variants: 98–839; mini_dft: 2–96"
    valid_values: []
    default: null
  variant:
    description: "Function variant encoding input/output precision"
    valid_values:
      - dft_hfx_hfl      # in: complex_hfx, out: complex_hfl, scratch required
      - dft_sfl_hfl      # in: complex_hfx, out: complex_hfl, scratch required
      - dft_hfx_sfl      # in: complex_hfx, out: complex_sfl, no scratch
      - dft_sfl_sfl      # in: complex_hfx, out: complex_sfl, no scratch
      - mini_dft_hfx_hfl # N<=96, in: complex_hfx, out: complex_hfl, no scratch
      - mini_dft_sfl_hfl # N<=96, in: complex_sfl, out: complex_hfl, no scratch
      - mini_dft_hfx_sfl # N<=96, in: complex_hfx, out: complex_sfl, no scratch
      - mini_dft_sfl_sfl # N<=96, in: complex_sfl, out: complex_sfl, no scratch
    default: dft_hfx_hfl

matlab_source:  nxp/dft/matlab/
c_source:       []
python_model:   framework/vspa_model/fft.py::r_dft
test_dir:       tests/dft/
doc:
  - nxp/dft/doc/DFT_Implementation_Plan.docx
  - nxp/dft/doc/DFT_Testplan.xlsx

depends_on: []

test_cases:
  - id: TC000
    params: {N: 12,  input_precision: half_fixed, output_precision: half}
    notes: ""
  - id: TC001
    params: {N: 28,  input_precision: half_fixed, output_precision: half}
    notes: ""
  - id: TC002
    params: {N: 43,  input_precision: half_fixed, output_precision: half}
    notes: ""
  - id: TC003
    params: {N: 96,  input_precision: half_fixed, output_precision: half}
    notes: ""
  - id: TC004
    params: {N: 97,  input_precision: half_fixed, output_precision: half}
    notes: "First N requiring full dft variant (>96)"
  - id: TC005
    params: {N: 139, input_precision: half_fixed, output_precision: half}
    notes: ""
  - id: TC006
    params: {N: 550, input_precision: half_fixed, output_precision: half}
    notes: ""
  - id: TC007
    params: {N: 839, input_precision: half_fixed, output_precision: half}
    notes: "Maximum N in testplan"
  - id: TC008
    params: {N: 12,  input_precision: half_fixed, output_precision: single}
    notes: ""
  - id: TC016
    params: {N: 12,  input_precision: single, output_precision: half}
    notes: ""

perf:
  target_efficiency: null
  cycles: 7638
  au_config: vspa2_16au
  notes: "PASS vspa2_16au using mini_dft_hfx_hfl_asm (N=96) test harness; re-measured runsim 2026-05-27"
---

# dft — Generic DFT (Decimation-in-Time, arbitrary N)

> Generic N-point complex DFT for arbitrary sequence lengths, complementing
> the power-of-2 ditfft/diffft kernels. Covers N from 2 to 839.

## Algorithm

Computes the generic DFT:

$$X[k] = \sum_{n=0}^{N-1} x(n)\, e^{-j\frac{2\pi kn}{N}}$$

Two families are provided:
- **`dft_xx_xx_asm`** — for N > 96, requires a scratch buffer
- **`mini_dft_xx_xx_asm`** — for N ∈ [2, 96], no scratch, more compact

## Function API

```c
// Full DFT (N > 96, requires scratch_p)
void dft_hfx_hfl_asm(cfixed16_t *in_p, cfixed16_t *scratch_p,
                     cfloat16_t *out_p, uint32_t n_dft);
void dft_sfl_hfl_asm(cfixed16_t *in_p, cfixed16_t *scratch_p,
                     cfloat16_t *out_p, uint32_t n_dft);
void dft_hfx_sfl_asm(cfixed16_t *in_p,
                     cfloat16_t *out_p,  uint32_t n_dft);
void dft_sfl_sfl_asm(cfixed16_t *in_p,
                     cfloat16_t *out_p,  uint32_t n_dft);

// Mini DFT (N ∈ [2,96], no scratch)
void mini_dft_hfx_hfl_asm(cfixed16_t  *in_p, cfloat16_t  *out_p, uint32_t n_dft);
void mini_dft_sfl_hfl_asm(cfloat32_t  *in_p, cfloat16_t  *out_p, uint32_t n_dft);
void mini_dft_hfx_sfl_asm(cfixed16_t  *in_p, cfloat32_t  *out_p, uint32_t n_dft);
void mini_dft_sfl_sfl_asm(cfloat32_t  *in_p, cfloat32_t  *out_p, uint32_t n_dft);
```

## Memory Requirements

**`dft_xx_xx_asm`** (N > 96):

| Buffer    | Min size (half-words)            | Alignment (half-words) | Allocated by |
|-----------|----------------------------------|------------------------|--------------|
| in_p      | 194 (hfx/hfl) / 388 (sfl)       | 64                     | Caller       |
| scratch_p | 388                              | 64                     | Caller       |
| out_p     | 194 (hfx/hfl) / 388 (sfl)       | 64                     | Caller       |

**`mini_dft_xx_xx_asm`** (N ∈ [2, 96], no scratch):

| Buffer | Min size (half-words)      | Alignment (half-words) | Allocated by |
|--------|---------------------------|------------------------|--------------|
| in_p   | 2 (hfx/hfl) / 4 (sfl)    | 64                     | Caller       |
| out_p  | 2 (hfx/hfl) / 4 (sfl)    | 64                     | Caller       |

## Input/Output Layout

| Port     | Shape | Type        | Variants               |
|----------|-------|-------------|------------------------|
| in_p     | [N]   | complex_hfx | all except mini_dft_sfl_* |
| in_p     | [N]   | complex_sfl | mini_dft_sfl_* |
| out_p    | [N]   | complex_hfl | *_hfl variants |
| out_p    | [N]   | complex_sfl | *_sfl variants |

## Precision Modes

| Variant         | Input dtype  | Output dtype | Scratch |
|-----------------|--------------|--------------|---------|
| `dft_hfx_hfl`   | complex_hfx  | complex_hfl  | Yes     |
| `dft_hfx_sfl`   | complex_hfx  | complex_sfl  | No      |
| `dft_sfl_hfl`   | complex_hfx  | complex_hfl  | Yes     |
| `dft_sfl_sfl`   | complex_hfx  | complex_sfl  | No      |
| `mini_dft_*`    | hfx or sfl   | hfl or sfl   | No      |

## Test Cases

Sourced from `DFT_Testplan.xlsx` (N range 12–839, 24 total TCs across precision combos):

| ID    | N   | Input prec   | Output prec | Notes           |
|-------|-----|-------------|-------------|-----------------|
| TC000 | 12  | half_fixed  | half        | mini_dft range  |
| TC003 | 96  | half_fixed  | half        | max mini_dft N  |
| TC004 | 97  | half_fixed  | half        | min full dft N  |
| TC007 | 839 | half_fixed  | half        | max N           |
| TC008 | 12  | half_fixed  | single      |                 |
| TC016 | 12  | single      | half        |                 |

## Known Constraints

- `dft_xx_xx_asm` supports N = 98–839.
- `mini_dft_xx_xx_asm` supports N = 2–96.
- Scratch buffer (388 half-words) required only for the full `dft` family.
- All buffers must be 64 half-word (32-word) aligned.

## References

- Implementation plan: `nxp/dft/doc/DFT_Implementation_Plan.docx`
- Testplan: `nxp/dft/doc/DFT_Testplan.xlsx`
- NXP vspa-lib: `submodules/la931x_vspa_common/vspa-lib/dft/`
