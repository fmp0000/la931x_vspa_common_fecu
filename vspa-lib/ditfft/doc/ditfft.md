---
kernel: ditfft
precision: [half_fixed, single]
status: sim_verified

inputs:
  - name: pIn
    shape: [N]
    dtype: complex_hfl        # half-float input for all variants
    alignment_words: 1
    description: "Complex FFT input. Natural order (DIT handles bit-reversal internally). For ifftDIT<N>_sfl, must be placed in bit-reversed order."

outputs:
  - name: pOut
    shape: [N]
    dtype: complex_hfx        # half_fixed for _hfl variants; complex_sfl for _sfl variants
    alignment_words: 32       # must be DMEM line aligned
    description: "FFT/IFFT output in linear order"

scratch:
  - name: ifftDITScratchBuffer
    size_words: "2*N"
    alignment_words: 32
    description: "Required only for ifftDIT<N>_sfl; allocated by caller"

parameters:
  N:
    description: "FFT/IFFT length (power of 2)"
    valid_values: [128, 512, 1024, 2048]
    default: 512
  variant:
    description: "Function variant: fftDIT<N>_hfl | ifftDIT<N>_hfl | fftDIT<N>_sfl | ifftDIT<N>_sfl"
    valid_values: [fftDIT_hfl, ifftDIT_hfl, fftDIT_sfl, ifftDIT_sfl]
    default: fftDIT_hfl

matlab_source:  nxp/ditfft/matlab/r_dit_fft.m
c_source:
  - nxp/ditfft/src/fftDIT512_hfl.sx
  - nxp/ditfft/src/fftDIT512_sfl.sx
  - nxp/ditfft/src/fftDIT1024_hfl.sx
  - nxp/ditfft/src/fftDIT2048_hfl.sx
  - nxp/ditfft/src/ditfftalloc.c
python_model:   framework/vspa_model/fft.py::r_dit_fft
test_dir:       tests/ditfft/
doc:
  - nxp/ditfft/doc/DITFFT_Implementation_plan.docx

depends_on: []

test_cases:
  - id: TC000
    params: {N: 512, variant: fftDIT_hfl}
    notes: "Reference configuration used in python model verification"
  - id: TC001
    params: {N: 128, variant: fftDIT_hfl}
    notes: ""
  - id: TC002
    params: {N: 1024, variant: fftDIT_hfl}
    notes: ""
  - id: TC003
    params: {N: 512, variant: ifftDIT_hfl}
    notes: ""
  - id: TC004
    params: {N: 512, variant: fftDIT_sfl}
    notes: "Single-precision output; pOut is complex_sfl (2*N words)"

perf:
  target_efficiency: "TBD"
  cycles: 25412
  au_config: vspa2_16au
  notes: "TC000 (N=512, fftDIT_hfl); PASS vspa2_16au; re-measured runsim 2026-05-27 (median of 3)"
---

# ditfft — Decimation-In-Time FFT / IFFT

> N-point complex FFT (and IFFT) using the Cooley-Tukey DIT radix-2 butterfly,
> optimised for the VSPA AU vector register architecture.

## Algorithm

The kernel computes the N-point discrete Fourier transform using the
decimation-in-time (DIT) approach. Input samples are in natural order; internal
bit-reversal is applied. Each stage performs radix-2 butterfly operations.

`fftDIT<N>_hfl` is mathematically equivalent to `y = (1/N) * fft(x, N)`.  
`ifftDIT<N>_hfl` is equivalent to `y = ifft(x, N)`.  
`fftDIT<N>_sfl` / `ifftDIT<N>_sfl` are the unscaled single-precision variants.

All inner butterfly stages are kept in the VRA (Vector Register Array),
flushing to DMEM only at the final stage — minimising memory traffic.

## Function API

```c
// half-fixed variants (pIn: complex_hfl, pOut: complex_hfx)
void fftDIT<N>_hfl (vspa_complex_float16 const *pIn, vspa_complex_fixed16 *pOut);
void ifftDIT<N>_hfl(vspa_complex_float16 const *pIn, vspa_complex_fixed16 *pOut);

// single-precision variants (pIn: complex_hfl, pOut: complex_sfl)
void fftDIT<N>_sfl (vspa_complex_float16 const *pIn, vspa_complex_float32 *pOut);
void ifftDIT<N>_sfl(vspa_complex_float16 const *pIn, vspa_complex_fixed16  *pOut);
```

N ∈ {128, 512, 1024, 2048} — separate `.sx` files per size.

## Memory Requirements

| Function            | Buffer          | Min size (words) | Alignment (words) | Allocated by |
|---------------------|-----------------|-----------------|-------------------|--------------|
| fftDIT\<N\>_hfl     | Input           | N               | 1                 | Caller       |
|                     | Output          | N               | 32                | Caller       |
| fftDIT\<N\>_sfl     | Input           | N               | 1                 | Caller       |
|                     | Output          | 2*N             | 32                | Caller       |
| ifftDIT\<N\>_hfl    | Input           | N               | 1                 | Caller       |
|                     | Output          | N               | 32                | Caller       |
| ifftDIT\<N\>_sfl    | Input           | N               | 1                 | Caller       |
|                     | Output          | N               | 32                | Caller       |
|                     | Scratch buffer  | 2*N             | 32                | Caller       |

**In-place operation**: supported for `fftDIT<N>_hfl` / `ifftDIT<N>_hfl` only;
when used in-place, the input buffer must also be 32-word aligned.

## Input/Output Layout

| Port  | Shape | Type        | Notes                                     |
|-------|-------|-------------|-------------------------------------------|
| pIn   | [N]   | complex_hfl | natural order; no pre-reordering needed   |
| pOut  | [N]   | complex_hfx | linear order; 2*N words for _sfl variants |

## Precision Modes

| Mode         | Input dtype  | Output dtype  | Equivalent MATLAB          |
|--------------|--------------|---------------|----------------------------|
| `half_fixed` | complex_hfl  | complex_hfx   | `(1/N)*fft(x,N)`           |
| `single`     | complex_hfl  | complex_sfl   | `fft(x,N)` (unscaled)      |

## Test Cases

| ID    | N    | Variant       | Notes                          |
|-------|------|---------------|-------------------------------|
| TC000 | 512  | fftDIT_hfl    | Reference / python-verified    |
| TC001 | 128  | fftDIT_hfl    |                                |
| TC002 | 1024 | fftDIT_hfl    |                                |
| TC003 | 512  | ifftDIT_hfl   |                                |
| TC004 | 512  | fftDIT_sfl    | Output buffer is 2*N words     |

## Known Constraints

- N must be a power of 2 in {128, 512, 1024, 2048} — separate assembly files per size.
- `fftDIT<N>_sfl` output buffer is `2*N` words (double size — float32 vs hfx).
- `ifftDIT<N>_sfl` requires a caller-allocated scratch buffer of 2*N words, 32-word aligned.
- In-place operation requires input to also be 32-word aligned.

## References

- Implementation plan: `nxp/ditfft/doc/DITFFT_Implementation_plan.docx`
- MATLAB oracle: `nxp/ditfft/matlab/r_dit_fft.m`
- Python model: `tests/framework/vspa_model.py::r_dit_fft`
