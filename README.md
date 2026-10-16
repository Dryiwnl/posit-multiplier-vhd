# posit-multiplier-vhdl

An 8-bit **Posit (es = 1) multiplier**, implemented in VHDL-2008 and verified exhaustively using GHDL and an independent Python reference model. The design was synthesised, placed and routed in AMD Vivado 2026.1 for a Xilinx Virtex-7 FPGA.

**Author:** [Matheus Viganó Schirrmann](https://github.com/Dryiwnl)  
**Institution:** Universidade Federal de Santa Catarina (UFSC) — ProtoFPGA

## Architecture

```text
             positA                          positB
                │                               │
                ▼                               ▼
        ┌──────────────┐                ┌──────────────┐
        │   Decoder A  │                │   Decoder B  │
        └──────┬───────┘                └───────┬──────┘
               │                                │
       ┌───────┴────────┐              ┌────────┴───────┐
       │                │              │                │
       ▼                │              │                ▼
   Fraction A           └──────┬───────┘           Fraction B
       │                       │                        │
       │                       ▼                        │
       │            ┌────────────────────┐              │
       │            │ Sign and Exponent  │              │
       │            │ Processing Unit    │              │
       │            └─────────┬──────────┘              │
       │                      │                         │
       ▼                      │                         ▼
       └───────────┐          │          ┌──────────────┘
                   ▼          │          ▼
               ┌───────────────────────────┐
               │    Mantissa Multiplier    │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │       Normalization       │◀── Regime/Exp
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │     Posit Packing         │
               │  Regime | Exp | Fraction  │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │     Rounding + Sign       │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │     Zero / NaR Handling   │
               └─────────────┬─────────────┘
                             │
                             ▼
                         positResult
```

The architecture is combinational. The top-level module integrates seven VHDL components:

| Module | Function |
|---|---|
| `decoder_posit.vhd` | Extracts sign, regime, exponent and fraction |
| `sign_and_exponent_PU.vhd` | Computes output sign, regime and exponent |
| `mantissa_multiplier.vhd` | Performs unsigned mantissa multiplication |
| `normalization.vhd` | Normalizes the product and adjusts its scale |
| `posit_component_packing.vhd` | Packs the Posit fields and handles saturation |
| `posit_rounding.vhd` | Applies round-to-nearest, ties-to-even |
| `posit_multiplier_top.vhd` | Connects the complete datapath and handles zero/NaR |

Detailed schematics:

- [RTL architecture](docs/figures/rtl_architecture.pdf)
- [Post-synthesis schematic](docs/figures/post_synthesis_schematic.pdf)

## How Posit multiplication works

For Posit(8,1), a nonzero finite number can be expressed as

\[
x=(-1)^s \times 4^k \times 2^e \times (1+f)
\]

where:

- \(s\) is the sign bit;
- \(k\) is the regime value;
- \(e\) is the exponent (`es = 1`);
- \(f\) is the fractional significand.

Multiplication can be decomposed into three independent operations.

**Sign:**

\[
s_y=s_a\oplus s_b
\]

**Scale:**

\[
k_y=k_a+k_b+\left\lfloor\frac{e_a+e_b}{2}\right\rfloor
\]

\[
e_y=(e_a+e_b)\bmod 2
\]

**Mantissa:**

\[
M_y=(1+f_a)(1+f_b)
\]

Each mantissa has an implicit leading 1. The hardware uses a 5×5-bit unsigned multiplier, producing a 10-bit result.

If the product is at least 2, normalization shifts the significand to the right and increments the exponent, propagating any exponent carry into the regime.

The normalized result is packed into Posit format and rounded using **round-to-nearest, ties-to-even**. Zero and NaR are handled at the top level.

Unlike logarithmic arithmetic, Posit multiplication requires a mantissa multiplier in addition to sign and scale processing.

## Repository layout

```text
rtl/                          VHDL arithmetic hardware
├── decoder_posit.vhd
├── sign_and_exponent_PU.vhd
├── mantissa_multiplier.vhd
├── normalization.vhd
├── posit_component_packing.vhd
├── posit_rounding.vhd
└── posit_multiplier_top.vhd

verification/                 Functional verification
├── posit_reference.py        Independent Python reference
├── results.txt               Exhaustive simulation output
└── tb/                       Module and top-level testbenches
    ├── tb_decoder_posit.vhd
    ├── tb_sign_and_exponent_PU.vhd
    ├── tb_mantissa_multiplier.vhd
    ├── tb_normalization.vhd
    ├── tb_posit_component_packing.vhd
    ├── tb_posit_rounding.vhd
    ├── tb_posit_multiplier_top.vhd
    └── tb_posit_exhaustive.vhd

vivado/
└── synth/
    ├── build.tcl             Automated synthesis and implementation
    ├── posit_mul_synth_wrapper.vhd
    ├── README.md
    └── reports/              Area, timing and power reports

docs/
└── figures/                  Vivado RTL and synthesis schematics
```

## Quick start

**Requirements:** Python 3, GHDL with VHDL-2008 support, and Vivado for FPGA implementation.

From the repository root, generate the expected results:

```bash
python verification/posit_reference.py
```

Compile the RTL in dependency order:

```bash
ghdl -a --std=08 rtl/decoder_posit.vhd
ghdl -a --std=08 rtl/sign_and_exponent_PU.vhd
ghdl -a --std=08 rtl/mantissa_multiplier.vhd
ghdl -a --std=08 rtl/normalization.vhd
ghdl -a --std=08 rtl/posit_component_packing.vhd
ghdl -a --std=08 rtl/posit_rounding.vhd
ghdl -a --std=08 rtl/posit_multiplier_top.vhd
```

Run the exhaustive verification:

```bash
ghdl -a --std=08 verification/tb/tb_posit_exhaustive.vhd
ghdl -e --std=08 tb_posit_exhaustive
ghdl -r --std=08 tb_posit_exhaustive
```

Expected result:

```text
TOTAL=65536 CORRECT=65536 ERRORS=0
simulation finished @65536ns
```

## Verification

The Python reference model independently decodes Posit bit patterns, computes the expected products and encodes the nearest representable results.

Every possible pair of 8-bit operands is tested:

\[
2^8 \times 2^8 = 65\,536
\]

| Test | Inputs | Result |
|---|---:|---|
| Full Posit multiplication | 65,536 pairs | No mismatches |
| Zero and NaR | Included in exhaustive verification | Passed |
| Positive and negative operands | Included in exhaustive verification | Passed |
| Rounding and saturation | Included in exhaustive verification | Passed |
| Vivado waveform testbench | 10 representative cases | Passed |

**Exhaustive verification result: 65,536 / 65,536 correct.**

[Full verification log](verification/results.txt)

### Vivado simulation waveform

Representative multiplication cases were simulated in Vivado using `tb_posit_multiplier_top.vhd`. The waveform displays the 8-bit Posit operands and result.

<!-- Add the screenshot after uploading docs/images/vivado_waveform.png -->

## Synthesis and implementation

The full Posit(8,1) multiplier was implemented using the following configuration:

| Parameter | Configuration |
|---|---|
| FPGA | Virtex-7 `xc7vx485tffg1157-1` |
| Tool | Vivado 2026.1 |
| Clock constraint | 10 ns |
| Synthesis | Out-of-context |
| Measurement | Registered input/output wrapper |
| Implementation | Placed and routed |
| Internal pipelining | None |

### Resource utilization

| Resource | Used |
|---|---:|
| Slice LUTs | **986** |
| CARRY4 | **163** |
| DSP blocks | **0** |
| Flip-flops | 36 |
| Block RAM | 0 |
| Slices | 281 |

The 36 flip-flops belong to the measurement wrapper. The arithmetic datapath itself is combinational.

### Timing results

| Metric | Result |
|---|---:|
| Clock constraint | 10.000 ns |
| Worst Negative Slack | −3.544 ns |
| Estimated critical period | **13.544 ns** |
| Estimated maximum frequency | **73.8 MHz** |
| Logic levels | 28 |
| Data-path delay | 13.510 ns |

The critical path crosses the full arithmetic datapath between an input register and an output register.

The path delay consists of approximately 24% logic delay and 76% routing delay.

Since the 10 ns constraint was not met, Fmax was estimated from the post-route setup slack:

\[
F_{\max}=\frac{1000}{10-(-3.544)}
\approx73.8\text{ MHz}
\]

### Power estimation

| Component | Estimated power |
|---|---:|
| Dynamic power | **24 mW** |
| Device static power | 241 mW |
| Total on-chip power | 265 mW |
| Overall confidence | Medium |

Power was estimated using Vivado vectorless activity propagation. No simulation switching-activity file was supplied, so these figures are estimates rather than physical measurements.

Detailed results:

- [Resource utilization](vivado/synth/reports/utilization.rpt)
- [Hierarchical utilization](vivado/synth/reports/utilization_hier.rpt)
- [Timing summary](vivado/synth/reports/timing.rpt)
- [Critical paths](vivado/synth/reports/paths.rpt)
- [Power report](vivado/synth/reports/power.rpt)

The measurement wrapper and automated synthesis script are available in [`vivado/synth/`](vivado/synth/).

## Status and next steps

The Posit(8,1) multiplier has been implemented and exhaustively verified for all 65,536 operand pairs.

Completed:

- RTL implementation of all seven modules.
- Module-level and integrated testbenches.
- Independent Python reference model.
- Exhaustive functional verification with no mismatches.
- Vivado synthesis and routed implementation.
- Resource utilization, critical-path and power estimation reports.

Planned work includes improving the hardware implementation, extending the technical documentation and carrying out a controlled comparison with alternative numerical formats.

## Documentation

- [RTL architecture](docs/figures/rtl_architecture.pdf) — RTL-level schematic.
- [Post-synthesis schematic](docs/figures/post_synthesis_schematic.pdf) — synthesised hardware structure.
- [Verification results](verification/results.txt) — exhaustive test summary.
- [Vivado implementation reports](vivado/synth/reports) — utilization, timing and power.

Technical documentation in Portuguese following ABNT formatting is being developed separately.

## References

1. J. L. Gustafson and I. T. Yonemoto, *Beating Floating Point at Its Own Game: Posit Arithmetic*, Supercomputing Frontiers and Innovations, 2017.
2. H. Zhang and S.-B. Ko, *Efficient Multiple-Precision Posit Multiplier*, IEEE International Symposium on Circuits and Systems (ISCAS), 2021.

## Author

**Matheus Viganó Schirrmann**  
Computer Engineering — Universidade Federal de Santa Catarina  
ProtoFPGA — Araranguá, Santa Catarina, Brazil

2026
