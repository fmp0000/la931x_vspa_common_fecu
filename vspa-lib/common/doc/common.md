---
kernel: common
precision: [mixed]
status: not_started
inputs: []
outputs: []
scratch: []
parameters: {}
matlab_source: "submodules/la931x_vspa_common/vspa-lib/common/matlab/"
c_source: []
sx_source: []
src: ""
python_model: ""
test_dir: ""
doc: []
etsi_refs: []
depends_on: []
test_cases: []
perf:
  target_efficiency: null
  c_cycles: null
  sx_cycles: null
  au_config: null
  notes: "Utility/common support functions; no single kernel API."
---

# common

> Shared MATLAB utilities and support scripts used by multiple kernels.

## Algorithm

This folder contains shared helper functions and scripts rather than one executable kernel.

## Function API

No standalone kernel entrypoint.

## Memory Requirements

Not applicable at folder level.

## Input/Output Layout

Not applicable at folder level.

## Precision Modes

Mixed support utilities.

## Test Cases

No standalone test cases at folder level.

## Known Constraints

- This is a shared support area; functionality is consumed by other kernel flows.

## References

- MATLAB utilities: submodules/la931x_vspa_common/vspa-lib/common/matlab/
- Scripts: submodules/la931x_vspa_common/vspa-lib/common/script/
