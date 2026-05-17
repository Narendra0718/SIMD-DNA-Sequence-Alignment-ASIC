# SIMD-DNA-Sequence-Alignment-ASIC
16-lane SIMD Smith-Waterman DNA Sequence Alignment Accelerator using Verilog HDL and Cadence ASIC Flow

## Project Overview

This project presents the complete RTL design, simulation, synthesis, and verification of a SIMD (Single Instruction Multiple Data) hardware accelerator for DNA sequence alignment using the Smith-Waterman local alignment algorithm.

The design implements a fixed-function ASIC-oriented architecture in Verilog HDL and was verified using the Cadence ASIC design flow.

The accelerator computes DNA sequence alignment using dynamic programming (DP) with 16-lane SIMD parallelism, allowing 16 DP cells to be processed simultaneously.

The project includes:
- RTL design in Verilog HDL
- Functional verification using Cadence Xcelium
- ASIC synthesis using Cadence Genus
- Gate-Level Simulation (GLS)
- Timing, area, and power analysis

---

# Motivation

DNA sequence alignment is a computationally intensive operation used in:
- Genome sequencing
- Mutation analysis
- Disease detection
- Bioinformatics research
- Genetic similarity analysis

The Smith-Waterman algorithm provides optimal local alignment accuracy but has high computational complexity:

O(n × m)

For long DNA sequences, software execution becomes extremely slow.

This project accelerates the algorithm using SIMD hardware parallelism.

---

# Smith-Waterman Algorithm

The Smith-Waterman algorithm computes local sequence alignment using dynamic programming.

Each DP matrix cell is computed as:

H(i,j) = max
(
Diagonal + Match/Mismatch,
Up + Gap,
Left + Gap,
0
)

Where:
- Diagonal → match/mismatch
- Up → insertion
- Left → deletion
- 0 → local alignment boundary

Scoring used in this implementation:

| Operation | Score |
|-----------|------|
| Match | +3 |
| Mismatch | -1 |
| Gap Penalty | -2 |

---

# SIMD Parallelism

This design uses a 16-lane SIMD architecture.

Meaning:
- Same operation executed on multiple data simultaneously
- 16 DP cells processed in parallel
- 128-bit SIMD datapath
- Each lane operates on 8-bit signed data

Advantages:
- Higher throughput
- Faster matrix computation
- Reduced execution time

---

# Architecture Overview

The top-level architecture consists of eight major modules.

## Top-Level Dataflow

1. Input DNA sequences loaded
2. SIMD controller initiates processing
3. Scoring units generate match/mismatch scores
4. SIMD PE array computes DP matrix rows
5. Row buffer stores previous row
6. Direction buffer stores traceback directions
7. Max-score tracker identifies optimal alignment
8. Traceback unit reconstructs alignment statistics

---
# RTL Modules

## 1. Scoring Unit (`scoring_unit.v`)

Computes match/mismatch score.

Function:
- Match → +3
- Mismatch → -1

Operates combinationally.

---

## 2. Gap Penalty Unit (`gap_penalty_unit.v`)

Provides constant gap penalty.

Gap penalty used:
- -2

Linear gap model used for hardware simplicity.

---

## 3. SIMD Processing Element (`simd_pe.v`)

Core compute unit.

Computes:
- Diagonal score
- Up score
- Left score

Final cell score:
max(diagonal, up, left, 0)

Also generates traceback direction.

---

## 4. SIMD PE Array (`simd_pe_array.v`)

Contains:
- 16 parallel SIMD processing elements

Computes one complete DP row in parallel.

---

## 5. DP Row Buffer (`dp_row_buffer.v`)

Stores previous DP row.

Used for:
- diagonal dependency
- upper dependency

---

## 6. Direction Buffer (`direction_buffer.v`)

Stores traceback direction bits.

Width:
- 512 bits

Used by traceback unit.

---

## 7. Max Score Tracker (`max_score_tracker.v`)

Tracks:
- maximum alignment score
- corresponding matrix coordinates

Implemented using comparator reduction tree.

This module forms the critical path of the design.

---

## 8. SIMD Controller (`simd_controller.v`)

FSM-based controller.

Responsibilities:
- generate load_row pulses
- control row processing
- maintain wait_cycle
- generate done signal

---

## 9. Traceback Unit (`traceback_unit.v`)

Reconstructs alignment path.

Calculates:
- matches
- mismatches
- insertions
- deletions
- mutations

---

# Project Folder Structure

```text
SIMD-DNA-Sequence-Alignment-ASIC/
│
├── rtl/
│   ├── top_module.v
│   ├── simd_pe.v
│   ├── simd_pe_array.v
│   ├── scoring_unit.v
│   ├── gap_penalty_unit.v
│   ├── max_score_tracker.v
│   ├── dp_row_buffer.v
│   ├── direction_buffer.v
│   ├── traceback_unit.v
│   ├── simd_controller.v
│
├── tb/
│   ├── tb_top_module.v
|   ├── gls_tb.v
│
├── synthesis/
│   ├── run_synthesis.tcl
│   ├── constraints.sdc
│   ├── synth_area.rpt
│   ├── synth_power.rpt
│   ├── synth_timing.rpt
│   ├── synth_qor.rpt
│
├── docs/
│   ├── SIMD_Project_Report.pdf
│
├── images/
│   ├── simd_rtl_waves.png
│   ├── simd_gls_waves.png
│   ├── simd_schematic.png
│
└── README.md
```

---

# RTL Simulation

RTL simulation was performed using Cadence Xcelium.

## Test Sequences

Reference:
```text
ACGTACGTACGTACGT
```

Sample:
```text
ACGAACGTACGTACCT
```

---

# RTL Waveform

![RTL Waveform](images/simd_rtl_waves.png)

---

# RTL Results

| Parameter | Value |
|-----------|------|
| Max Score | 40 |
| Matches | 14 |
| Mismatches | 2 |
| Insertions | 0 |
| Deletions | 0 |
| Mutations | 2 |

---

# Waveform Explanation

1. Reset initializes all registers
2. Start pulse begins computation
3. DP rows computed sequentially
4. Max score increases progressively
5. Traceback reconstructs alignment
6. tb_done indicates completion

---

# Synthesis

Logical synthesis performed using:
- Cadence Genus 21.14

Target:
- Standard-cell ASIC library

Clock Constraint:
- 10 ns (100 MHz)

---

# Synthesis Schematic

![Schematic](images/simd_schematic.png)

---

# Synthesis Results

| Metric | Value |
|--------|------|
| Frequency | 100 MHz |
| Total Cell Area | 40,715.9 |
| Standard Cells | 5379 |
| Sequential Cells | 810 |
| Combinational Cells | 4569 |
| Slack | +0.6 ps |
| Violating Paths | 0 |
| Total Power | 4.567 mW |

---

# Timing Analysis

## Critical Path

Critical path exists in:
- max-score comparator tree

Reason:
- multiple comparator stages
- deep combinational logic

Critical path delay:
- approximately 17.28 ns

A 2-cycle multi-cycle path constraint was applied.

---

# Power Analysis

| Power Type | Percentage |
|------------|------------|
| Internal Power | 74.42% |
| Switching Power | 21.33% |
| Leakage Power | 4.25% |

Dynamic power dominates due to SIMD switching activity.

---

# Gate-Level Simulation (GLS)

GLS performed using:
- synthesized netlist
- back-annotated timing delays

Purpose:
- timing-accurate verification

---

# GLS Waveform

![GLS Waveform](images/simd_gls_waves.png)

---

# GLS Observations

- Functional outputs match RTL
- Real gate delays included
- Small glitches observed in combinational logic
- Final latency increased due to propagation delays

---

# Key Design Optimizations

## SIMD Parallelism
- 16 DP cells computed simultaneously

## Fixed-Function Hardware
- removed instruction overhead
- reduced power consumption

## Linear Gap Model
- simplified hardware implementation

## Single Controller
- reduced control complexity

## Wait-Cycle Stabilization
- improved timing reliability

---

# Design Trade-Offs

| Optimization | Trade-Off |
|--------------|-----------|
| SIMD Parallelism | Increased area |
| Fixed-function Design | Reduced flexibility |
| High Performance | Tight timing slack |
| Simplified Gap Model | Reduced biological accuracy |

---

# Comparison with BioBlaze

| Parameter | BioBlaze | This Work |
|-----------|----------|-----------|
| SIMD Width | 128-bit | 128-bit |
| Architecture | ASIP | Fixed-function RTL |
| Traceback | Software | Hardware |
| Power | 24.2 mW | 4.567 mW |
| Programmability | Yes | No |

---

# What We Learned

This project provided practical understanding of:
- SIMD hardware design
- Dynamic programming acceleration
- ASIC synthesis flow
- RTL vs GLS verification
- Timing closure
- Critical path optimization
- Area-power-performance trade-offs

---

# Future Scope

Possible future improvements:

## Multi-Core Extension
Support multiple alignment engines.

## Affine Gap Penalty
Improve biological accuracy.

## Pipeline Optimization
Improve timing slack.

## Advanced Technology Node
Migrate to smaller CMOS nodes.

## Distributed Max Tracking
Reduce critical path delay.

---

# Tools Used

| Tool | Purpose |
|------|---------|
| Verilog HDL | RTL Design |
| Cadence Xcelium | RTL + GLS Simulation |
| Cadence Genus | Logical Synthesis |

---

# Reference

This work is inspired by the BioBlaze SIMD ASIP architecture for DNA sequence alignment.

---

# License

This project is intended for academic and educational purposes.

# NARENDRA
Department of ECE-VLSI  
Indian Institute of Information Technology Senapati Manipur
