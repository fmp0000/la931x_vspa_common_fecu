# VSPA Common Repository

vspa_common_la9310 repository contains all the vspa kernel components for
enabling LA9310 VSPA firmware development. It includes vspa-sdk providing
basic support of la9310 SOC support, and vspa-lib which provides a set
of basic optimized VSPA kernels.

# Requirements

- CodeWarrior for VSPA 10.3.0 

# Libraries

This repository includes 2 libraries for VSPA development:
- `vspa-sdk` library provides a set of include and source files to use VSPA
  peripherals, adds support for missing intrinsics, and targets VSPA3-based
  system-on-chips. 
- `vspa-lib` library provides optimized implementations of generic DSP functions
  not specific to any particular application. 

## Generate test vectors using matlab

To generate VSPA kernel test vectors execute matlab script under related CW project
- run `${ProjDirPath}/[..]/vspa-lib/<kernel>/<kernel>_cwproj/matlab`

## Execute regression testing tcl scripts 

- Import existing project in CW `${ProjDirPath}`
- Compile project 
- open Debugger Shell 
-  cd `<kernel>_cwproj`
-  source ./scripts/<testBench>.tcl


