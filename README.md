# Posit(8,1) Multiplier in VHDL

An 8-bit Posit multiplier with `es = 1`, implemented in VHDL as part of a hardware arithmetic research project at **ProtoFPGA — Universidade Federal de Santa Catarina (UFSC)**.

The design implements a combinational multiplication pipeline, including decoding, mantissa multiplication, normalization, packing, rounding, and special-value handling.

## 1. Architecture

The multiplier is composed of seven VHDL modules:

| Module | Description |
|---|---|
| `decoder_posit.vhd` | Decodes the Posit operands |
| `sign_and_exponent_PU.vhd` | Computes the result sign, regime, and exponent |
| `mantissa_multiplier.vhd` | Multiplies the operand mantissas |
| `normalization.vhd` | Normalizes the product and preserves discarded precision |
| `posit_component_packing.vhd` | Reconstructs the Posit representation and handles saturation |
| `posit_rounding.vhd` | Performs round-to-nearest, ties-to-even, and applies the sign |
| `posit_multiplier_top.vhd` | Integrates the complete multiplier and handles zero and NaR |

### RTL architecture

[RTL schematic](docs/figures/rtl_architecture.pdf)

### Post-synthesis architecture

[Post-synthesis schematic](docs/figures/post_synthesis_schematic.pdf)

## 2. Functional Verification

Functional verification was performed using **GHDL 6.0.0** and **Python 3.12.6**.

An independent Python reference model generates the expected outputs for every pair of 8-bit Posit operands.

The VHDL testbench compares these reference values with the output of the hardware implementation.

| Metric | Result |
|---|---:|
| Total operand pairs | 65,536 |
| Correct results | 65,536 |
| Mismatches | 0 |
| Functional coverage of operand pairs | 100% |

The exhaustive test includes positive and negative operands, zero, NaR, rounding cases, and representable extremes.

Verification files are available in [`verification/`](verification/).

## 3. FPGA Synthesis and Implementation

The design was synthesized, placed, and routed using **Vivado 2026.1**.

**Target FPGA:** Xilinx Virtex-7 `xc7vx485tffg1157-1`.

A separate measurement wrapper registers the input and output signals. The original arithmetic unit remains combinational.

The implementation uses out-of-context synthesis, with a 10 ns timing constraint.

### Resource utilization

| Resource | Post-implementation utilization |
|---|---:|
| Slice LUTs | 986 |
| CARRY4 | 163 |
| Flip-flops | 36 |
| DSP blocks | 0 |
| Block RAM | 0 |
| Slices | 281 |

The 36 flip-flops belong to the measurement wrapper.

### Timing

| Metric | Result |
|---|---:|
| Clock constraint | 10 ns |
| Worst Negative Slack | −3.544 ns |
| Estimated minimum clock period | 13.544 ns |
| Estimated Fmax | 73.8 MHz |
| Critical path logic levels | 28 |

The implemented design does not meet the original 100 MHz constraint. The reported Fmax is estimated from the routed timing analysis.

### Power

| Metric | Estimated power |
|---|---:|
| Dynamic power | 24 mW |
| Static device power | 241 mW |
| Total on-chip power | 265 mW |

Power values were estimated using Vivado's vectorless activity propagation, without an externally supplied switching-activity file. Overall estimation confidence is medium.

## 4. Repository Structure

```text
posit-multiplier-vhdl/
├── docs/
│   └── figures/
├── rtl/
│   └── *.vhd
├── verification/
│   ├── posit_reference.py
│   ├── results.txt
│   └── tb/
│       └── *.vhd
├── vivado/
│   └── synth/
│       ├── build.tcl
│       ├── posit_mul_synth_wrapper.vhd
│       ├── README.md
│       └── reports/
└── README.md
```

## 5. Reproducing the Results

### Functional verification

Requirements: Python 3 and GHDL with VHDL-2008 support.

Generate all expected results:

```powershell
python verification/posit_reference.py
```

Compile the RTL modules in dependency order, then compile and run `verification/tb/tb_posit_exhaustive.vhd` with GHDL.

The testbench compares all 65,536 combinations against the generated reference vectors.

Expected verification summary:

```text
TOTAL=65536 CORRECT=65536 ERRORS=0
```

### FPGA synthesis

Run the automated synthesis and implementation script from the `vivado/synth/` directory in Vivado batch mode.

The script produces utilization, timing, critical-path, and power reports.

The generated measurement reports are available in [`vivado/synth/reports/`](vivado/synth/reports/).

## 6. Known Limitations

- The current implementation has a fixed 8-bit Posit format with `es = 1`.
- The arithmetic datapath is combinational and has no internal pipeline registers.
- Timing and power results depend on the selected FPGA, tool version, constraints, and implementation strategy.
- Power is estimated rather than measured on physical hardware.

## 7. Project Information

**Engineer:** Matheus Viganó Schirrmann  
**Institution:** Universidade Federal de Santa Catarina (UFSC)  
**Research group:** ProtoFPGA  
**Language:** VHDL  
**Simulation:** GHDL / Vivado  
**Synthesis:** Vivado 2026.1

This project is part of a broader investigation of numerical representations and FPGA-based arithmetic hardware.
