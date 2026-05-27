---
kernel: diffft
precision: [half_fixed, half, single]
status: sim_verified

inputs:
  - name: pIn
    shape: [N]
    dtype: complex_hfx
    alignment_words: 1        # NOT vector-aligned; may be any alignment
    description: "FFT input — read from a circular buffer"
  - name: pBase
    shape: null
    dtype: pointer
    alignment_words: 32
    description: "Base pointer of the circular input buffer"
  - name: cbuffSize
    shape: null
    dtype: uint32
    alignment_words: null
    description: "Circular buffer size in half-words"

outputs:
  - name: pOut
    shape: [N]                # hfx variants: [N]; sfl variants: [2*N words]
    dtype: complex_hfl        # hfl or hfx or sfl depending on variant
    alignment_words: 32
    description: "FFT output — in BIT-REVERSED order"

scratch: []

parameters:
  N:
    description: "FFT/IFFT size (power of 2)"
    valid_values: [64, 128, 256, 512]
    default: 512
  direction:
    description: "Forward FFT or Inverse FFT"
    valid_values: [fft, ifft]
    default: fft
  variant:
    description: "Encoding of input/output data types"
    valid_values:
      - hfx_sfl    # in: complex_hfx, out: complex_sfl
      - hfx_hfl    # in: complex_hfx, out: complex_hfl
      - hfx_hfx    # in: complex_hfx, out: complex_hfx
    default: hfx_sfl

matlab_source:  nxp/diffft/matlab/
c_source:       []
python_model:   framework/vspa_model/fft.py::r_dif_fft
test_dir:       tests/diffft/
doc:
  - nxp/diffft/doc/DIFFFT_Implementation_plan.docx
  - nxp/diffft/doc/DIFFFT_testplan.xlsx

depends_on: []

test_cases:
  - id: TC000
    params: {N: 64,  direction: fft,  variant: hfx_sfl}
    notes: "min N forward FFT"
  - id: TC001
    params: {N: 128, direction: fft,  variant: hfx_sfl}
    notes: ""
  - id: TC002
    params: {N: 256, direction: fft,  variant: hfx_sfl}
    notes: ""
  - id: TC003
    params: {N: 512, direction: fft,  variant: hfx_sfl}
    notes: "max N forward FFT"
  - id: TC004
    params: {N: 64,  direction: ifft, variant: hfx_sfl}
    notes: "min N inverse FFT"
  - id: TC005
    params: {N: 512, direction: ifft, variant: hfx_sfl}
    notes: "max N inverse FFT"
  - id: TC006
    params: {N: 512, direction: fft,  variant: hfx_hfl}
    notes: ""
  - id: TC007
    params: {N: 512, direction: fft,  variant: hfx_hfx}
    notes: ""

perf:
  target_efficiency: null
  cycles: 50734
  au_config: vspa2_16au
  notes: "PASS vspa2_16au using fftDIF512_hfx_hfx test harness; re-measured runsim 2026-05-27 (median of 3)"
---

# diffft — Decimation-in-Frequency FFT/IFFT from Circular Buffer

> Power-of-2 complex FFT (DIF architecture) that reads input directly from a
> circular buffer. Produces output in **bit-reversed order** (opposite of ditfft
> which produces natural order).

## Algorithm

Standard Decimation-in-Frequency FFT. Unlike ditfft (DIT, natural-order output
from linear input), diffft:
- Reads input from a **circular buffer** via `pBase`/`cbuffSize`
- Produces output in **bit-reversed order**
- Complements ditfft: use diffft then reorder, or use ditfft on pre-bit-reversed input

$$X[k] = \sum_{n=0}^{N-1} x(n)\, W_N^{nk}, \quad W_N = e^{-j2\pi/N}$$

## Function API

```c
// Forward FFT — 6 variants (direction × output_dtype)
void fftDIF64_hfx_sfl_asm   (cfixed16_t *pIn, cfloat32_t *pOut,
                              cfixed16_t *pBase, uint32_t cbuffSize);
void fftDIF128_hfx_sfl_asm  (cfixed16_t *pIn, cfloat32_t *pOut,
                              cfixed16_t *pBase, uint32_t cbuffSize);
void fftDIF256_hfx_sfl_asm  (cfixed16_t *pIn, cfloat32_t *pOut,
                              cfixed16_t *pBase, uint32_t cbuffSize);
void fftDIF512_hfx_sfl_asm  (cfixed16_t *pIn, cfloat32_t *pOut,
                              cfixed16_t *pBase, uint32_t cbuffSize);

void fftDIF512_hfx_hfl_asm  (cfixed16_t *pIn, cfloat16_t *pOut,
                              cfixed16_t *pBase, uint32_t cbuffSize);

void fftDIF512_hfx_hfx_asm  (cfixed16_t *pIn, cfixed16_t *pOut,
                              cfixed16_t *pBase, uint32_t cbuffSize);

// Inverse FFT — same signature families
void ifftDIF64_hfx_sfl_asm  (cfixed16_t *pIn, cfloat32_t *pOut, ...);
void ifftDIF128_hfx_sfl_asm (cfixed16_t *pIn, cfloat32_t *pOut, ...);
void ifftDIF256_hfx_sfl_asm (cfixed16_t *pIn, cfloat32_t *pOut, ...);
void ifftDIF512_hfx_sfl_asm (cfixed16_t *pIn, cfloat32_t *pOut, ...);
void ifftDIF512_hfx_hfl_asm (cfixed16_t *pIn, cfloat16_t *pOut, ...);
void ifftDIF512_hfx_hfx_asm (cfixed16_t *pIn, cfixed16_t *pOut, ...);
```

## Memory Requirements

| Buffer    | Size (half-words) | Alignment (half-words) | Allocated by |
|-----------|-------------------|------------------------|--------------|
| pIn       | N                 | 1 (any)                | Caller       |
| pOut      | N (hfl/hfx) or 2*N (sfl) | 32              | Caller       |
| pBase     | circular buf base | 32                     | Caller       |

## Key Differences vs ditfft

| Feature          | ditfft                | diffft                  |
|------------------|-----------------------|-------------------------|
| Architecture     | DIT                   | DIF                     |
| Input layout     | Linear array          | Circular buffer         |
| Output order     | Natural (linear)      | Bit-reversed            |
| N values         | 64, 128, 256, 512     | 64, 128, 256, 512       |
| Input alignment  | Must be vector-aligned| Any alignment (align=1) |

## Known Constraints

- `cbuffSize` must be passed in half-words.
- `pIn` may point anywhere in the circular buffer — it does **not** need to be at `pBase`.
- Output in bit-reversed order; caller must reorder if natural frequency order is needed.
- `hfx_sfl` output buffers are 2×N half-words (float32); `hfx_hfl`/`hfx_hfx` are N half-words.

## References

- Implementation plan: `nxp/diffft/doc/DIFFFT_Implementation_plan.docx`
- Testplan: `nxp/diffft/doc/DIFFFT_testplan.xlsx`
- NXP vspa-lib: `submodules/la931x_vspa_common/vspa-lib/diffft/`
