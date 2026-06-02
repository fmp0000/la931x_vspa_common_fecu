# la931x_vspa_common — Kernel Regression Tests

Standalone instructions for running the VSPA kernel regression suite on a native Linux host.

## Prerequisites

**VSPA toolchain** — must contain `bin/fsvspacc`.  
The script auto-detects `/opt/VSPA_Tools_vbeta_14_00_781` if it exists; otherwise set `VSPA_TOOL` explicitly:

```sh
export VSPA_TOOL=/path/to/VSPA_Tools
```

**Simulator** — `runsim` binary must be on the path or at one of:
- `/opt/ccssim2/bin/runsim` (auto-detected)
- `environment/ccssim2/bin/runsim` (auto-detected when running from the parent repo)
- Explicit: `export SIMULATOR_PATH=/path/to/ccssim2/bin/runsim`

## Run the full regression

```sh
# AU=16 is the default
VSPA_TOOL=/path/to/VSPA_Tools bash tools/regression_cycles_all.sh

# Specify AU count explicitly
VSPA_TOOL=/path/to/VSPA_Tools bash tools/regression_cycles_all.sh 16
```

A CSV report is written to `build/reports/regression_<timestamp>.csv` with columns `kernel,status,cycles`.  
The `build/` directory is gitignored.

## Run a single kernel

```sh
VSPA_TOOL=/path/to/VSPA_Tools make -C vspa-lib/<kernel>/tests AU=16 test
```

Add `CYCLES=--cycles` to measure cycle counts (slower):

```sh
VSPA_TOOL=/path/to/VSPA_Tools make -C vspa-lib/<kernel>/tests AU=16 CYCLES=--cycles test
```

## Run an ELF directly

```sh
python3 vspa-lib/tools/run_sim.py <path/to/kernel.elf> vspa2_16au
python3 vspa-lib/tools/run_sim.py <path/to/kernel.elf> vspa2_16au --cycles
```
