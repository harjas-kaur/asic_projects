# AXI-Lite to APB Bridge RTL-to-GDSII ASIC Implementation, Pipeline Optimization and Assertion-Based Verification

| Baseline | Pipelined |
|----------|-----------|
| ![Baseline GDS](images/baseline_gds.png) | ![Pipelined GDS](images/pipelined_gds.png) |

---

## Project Overview

This project implements an AXI-Lite to APB bridge and takes it through a complete RTL-to-GDSII ASIC implementation flow using the OpenLane/OpenROAD toolchain and the Sky130 PDK.

The work consists of two implementations:

- Baseline AXI-Lite to APB bridge
- Pipelined AXI-Lite to APB bridge

The pipelined architecture was developed to study how small RTL microarchitectural changes affect timing closure and physical implementation metrics after synthesis and place-and-route.

In addition to backend implementation, a lightweight SystemVerilog Assertion (SVA) based verification environment was developed to validate protocol sequencing and handshake behaviour of the bridge.

---

# Project Objectives

- Implement an AXI-Lite to APB bridge in an ASIC design flow
- Complete RTL-to-GDSII implementation using OpenLane
- Compare backend QoR between baseline and pipelined RTL
- Improve timing by reducing critical combinational path depth
- Validate protocol behaviour using SystemVerilog Assertions

---

# Bridge Architecture

## Original Architecture

The original bridge uses a finite state machine (FSM) to translate AXI-Lite read and write transactions into APB transactions.

The controller directly processes incoming AXI requests and generates APB control signals, address decoding and transaction sequencing in the same datapath.

This implementation is functionally correct but places a relatively large amount of combinational logic between registers, creating longer critical timing paths.

---

## Pipelined Architecture

To improve timing closure, a pipeline stage was inserted at the AXI input interface.

Registers were added for:

- Read address
- Write address
- Read valid
- Write valid
- Burst type
- Burst length
- Write data

Instead of driving the FSM directly from AXI inputs, the FSM operates on registered pipeline signals.

The objective was to shorten the longest combinational paths while preserving the functional behaviour of the bridge.

---

# Design Features

- AXI-Lite master interface
- APB slave interface
- FSM-based protocol controller
- Read transaction support
- Write transaction support
- Burst transaction handling
- Parameterized state machine
- Synthesizable Verilog RTL
- Pipelined architecture for timing optimization

---

# Toolchain

| Tool | Purpose |
|------|---------|
| OpenLane | RTL-to-GDSII flow |
| OpenROAD | Physical implementation and STA |
| Yosys | Logic synthesis |
| Verilator | RTL linting |
| Icarus Verilog | RTL simulation |
| GTKWave | Waveform analysis |
| EDA Playground | SystemVerilog assertion verification |
| Magic | DRC and layout visualization |
| KLayout | GDS visualization |
| Sky130 | 130 nm open-source process |

---

# RTL-to-GDSII Flow

Both architectures were taken through the complete OpenLane implementation flow.

The completed stages include:

- RTL linting
- Logic synthesis
- Floorplanning
- Tapcell insertion
- Power distribution network generation
- Global placement
- Detailed placement
- Clock Tree Synthesis (CTS)
- Global routing
- Detailed routing
- Static Timing Analysis
- Design Rule Checking (DRC)
- GDSII generation

---

# SystemVerilog Assertion Verification

A lightweight assertion-based verification environment was developed using SystemVerilog Assertions (SVA).

Assertions were written separately from the RTL to verify protocol behaviour during simulation.

The implemented assertions check:

- AXI read address handshake
- AXI write address handshake
- AXI write data handshake
- APB reset behaviour
- APB protocol sequencing

The assertion source is located in:

```
AXI-to-APB-Bridge/
    bridge_assertions.sv
```

The assertion module can be compiled together with the pipelined RTL located in the OpenLane implementation directory.

Simulation was performed on EDA Playground.

During development, temporary protocol violations were intentionally introduced in the testbench to verify that the assertions correctly detected illegal protocol behaviour before restoring the original implementation.

---

# QoR Comparison

## Timing Comparison (5 ns Clock Constraint)

| Metric | Baseline | Pipelined |
|---------|----------|-----------|
| Worst Negative Slack (WNS) | -0.538 ns | -0.155 ns |
| Total Negative Slack (TNS) | -6.516 ns | -0.707 ns |
| Estimated Maximum Frequency | ~180 MHz | ~194 MHz |

---

## Physical Design Comparison

| Metric | Baseline | Pipelined |
|---------|----------|-----------|
| Synthesized Area | ~8765 µm² | ~2444 µm² |
| Post-Optimization Area | ~4973 µm² | ~1051 µm² |
| Final Standard Cell Count | ~721 | ~215 |
| Standard Cell Utilization | ~41.8% | ~41.8% |
| DRC | Passed | Passed |

---

# Metric Definitions

### Worst Negative Slack (WNS)

The largest setup timing violation in the design.

A value closer to **0 ns** indicates better timing closure.

---

### Total Negative Slack (TNS)

The sum of all negative timing slack across the design.

Lower magnitude indicates fewer overall timing violations.

---

### Estimated Maximum Frequency

Approximate maximum clock frequency inferred from static timing analysis after implementation.

---

### Synthesized Area

Total standard-cell area reported after logic synthesis.

---

### Post-Optimization Area

Area after placement and optimization during physical implementation.

---

### Standard Cell Utilization

Percentage of available core area occupied by standard cells.

---

### DRC

Design Rule Check verifies that the final layout satisfies manufacturing rules required by the Sky130 technology.

---

# Results

The pipelined implementation reduced the worst timing violation from

```
-0.538 ns
```

to

```
-0.155 ns
```

while increasing the estimated operating frequency from approximately

```
180 MHz
```

to

```
194 MHz.
```

The complete OpenLane flow successfully generated DRC-clean GDSII layouts for both implementations.

---

# Layout Comparison

## GDSII

| Baseline | Pipelined |
|----------|-----------|
| ![Baseline](images/baseline_gds.png) | ![Pipelined](images/pipelined_gds.png) |

---

## Floorplan

| Baseline | Pipelined |
|----------|-----------|
| ![Baseline](images/baseline_floorplan.png) | ![Pipelined](images/pipelined_floorplan.png) |

---

## Routed Layout

| Baseline | Pipelined |
|----------|-----------|
| ![Baseline](images/baseline_routing.png) | ![Pipelined](images/pipelined_routing.png) |

---

# Repository Structure

```
.
├── AXI-to-APB-Bridge/
│   ├── bridge_assertions.sv
│   ├── bridge.v
│   ├── axi_slave.v
│   ├── apb.v
│   └── testbenches/
│
├── axi_apb_openlane/
│
├── axi_apb_pipelined_openlane/
│
├── images/
│
└── README.md
```

---

# Acknowledgements

The baseline AXI-Lite to APB bridge RTL was developed using the SURE Trust AXI-to-APB Bridge project as a reference.

The RTL was subsequently modified and extended with:

- RTL pipeline optimization
- OpenLane/OpenROAD RTL-to-GDSII implementation
- QoR comparison between baseline and pipelined architectures
- SystemVerilog assertion-based verification
- Timing analysis and documentation

Original reference:

https://github.com/sure-trust/VLSI-Project-AXI-to-APB-Bridge

---

# Author

**Harjas Kaur**

B.Tech Electrical and Electronics Engineering  
Indian Institute of Technology Ropar

Interested in RTL Design, ASIC Physical Design, Computer Architecture and Digital VLSI.