
# Day 26 — Valid-Ready Buffer Design and Verification

<p align="center">
  <b>Digital VLSI | Verilog RTL | Functional Verification | Cadence Genus</b>
</p>

<p align="center">
  Specification → RTL → Testbench → Simulation → Synthesis → Area → Power → Timing → PPA Review
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Project-Valid--Ready%20Buffer-blue" alt="Project">
  <img src="https://img.shields.io/badge/HDL-Verilog-purple" alt="Verilog HDL">
  <img src="https://img.shields.io/badge/Simulation-Cadence%20NCSim-green" alt="Cadence NCSim">
  <img src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange" alt="Cadence Genus">
  <img src="https://img.shields.io/badge/Checks-64%20Reported%20Pass-success" alt="Reported checks">
</p>

---

## 1. Project Overview

This project implements and verifies a **Valid-Ready Buffer** using Verilog RTL. It explores data storage, valid-state tracking, handshake control, backpressure, and buffer operation under different input and output conditions.

The design was simulated using Cadence NCSim and synthesized using Cadence Genus. The available reports were used to analyze the hierarchy, standard-cell mapping, area, estimated power, and a reported setup timing path.

### Key Highlights

- Verilog RTL design and module hierarchy.
- Self-checking testbench and functional simulation.
- Valid-ready handshake and backpressure scenarios.
- Reset, data load, hold, replacement, and consumption checks.
- Cadence Genus synthesis and technology mapping.
- Standard-cell area and hierarchy analysis.
- Activity-based power estimation.
- Setup timing and slack calculation.
- PPA review with explicit evidence limitations.

---

## 2. Project Information

| Parameter | Details |
|---|---|
| Project | Valid-Ready Buffer Design and Verification |
| Domain | Digital VLSI / RTL Design / Functional Verification |
| HDL | Verilog |
| Simulation | Cadence NCSim |
| Synthesis | Cadence Genus 21.14-s082_1 |
| Technology library | `tsmc18` |
| Top module | `top_valid_ready` |
| Main buffer module | `valid_ready_buffer` |
| Reported simulation checks | 64 pass, 0 fail |
| Simulation completion | 157 ns |
| Standard-cell instances | 34 |
| Reported cell area | 798.336 library area units |
| Estimated total power | 79.2611 µW |
| Reported setup-path slack | +6.787 ns |
| Physical-design status | Post-route PPA closure not established |

> **Measurement notes**
>
> - The reported area unit has not been confirmed as µm².
> - Power is based on activity frame `/stim#0/frame#0`.
> - The timing result applies to one reported setup path, not necessarily every path in the design.
> - No post-route or extracted-parasitic results were supplied.

---

## 3. Design Objectives

1. Understand valid-ready handshaking.
2. Implement data storage and valid-state tracking.
3. Verify reset, load, and hold behavior.
4. Test input acceptance and output consumption.
5. Verify buffer stall and backpressure behavior.
6. Check data replacement and valid-state transitions.
7. Run a self-checking testbench using Cadence NCSim.
8. Inspect the simulation results and waveform database.
9. Synthesize the design using Cadence Genus.
10. Analyze mapped cells, area distribution, power, and timing.
11. Identify verification gaps before optimizing the RTL.
12. Establish a baseline for future PPA comparisons.

---

## 4. Design Hierarchy

```text
top_valid_ready
└── u_buffer (valid_ready_buffer)
    ├── u_data_register (data_register)
    ├── u_handshake (handshake_logic)
    │   ├── u_input_and (and_gate)
    │   └── u_output_and (and_gate_2)
    ├── u_ready_logic (ready_logic)
    │   └── u_or (or_gate)
    └── u_valid_register (valid_register)
```

### Module Responsibilities

| Instance | Module | Purpose indicated by the hierarchy |
|---|---|---|
| `u_buffer` | `valid_ready_buffer` | Main buffer module |
| `u_data_register` | `data_register` | Data storage |
| `u_handshake` | `handshake_logic` | Handshake control |
| `u_input_and` | `and_gate` | Input-side logic |
| `u_output_and` | `and_gate_2` | Output-side logic |
| `u_ready_logic` | `ready_logic` | Ready-generation logic |
| `u_or` | `or_gate` | OR logic within ready logic |
| `u_valid_register` | `valid_register` | Valid-state storage |

This hierarchy is based on the supplied synthesis report. Exact Boolean equations and signal connectivity should be confirmed against the RTL source.

---

## 5. Valid-Ready Handshake Fundamentals

In a conventional synchronous valid-ready interface, a transfer occurs at the active sampling edge when both `valid` and `ready` are asserted.

```verilog
transfer = valid & ready;
```

- **Valid:** The producer indicates that the presented data is valid.
- **Ready:** The receiver indicates that it can accept data.
- **Transfer:** Both signals are asserted at the sampling edge.
- **Backpressure:** The receiver deasserts `ready` when it cannot accept a transfer.
- **Data hold:** While a transfer is stalled, the interface must preserve the required data and control state according to its specification.

The exact protocol behavior must be confirmed against the implemented RTL and testbench.

---

## 6. Functional Verification

### Simulation Summary

| Metric | Reported result |
|---|---|
| Total checks | 64 |
| Failed checks | 0 |
| Simulation completion | 157 ns |
| Termination | `$finish` |
| Testbench summary | `ALL TESTS PASSED` |

### Reported Check Distribution

| Test category | Checks | Reported result |
|---|---:|---|
| Gate-level logic | 12 | PASS |
| Ready logic | 4 | PASS |
| Handshake logic | 36 | PASS |
| Data-register reset | 1 | PASS |
| Data-register load and hold | 2 | PASS |
| Valid register | 3 | PASS |
| Buffer reset and input | 2 | PASS |
| Buffer stall and hold | 2 | PASS |
| Replace and consume data | 3 | PASS |
| Top-module integration | 3 | PASS |
| **Total** | **64** | **64 reported pass** |

### Selected Reported Scenarios

| Scenario | Actual | Expected | Reported result |
|---|---|---|---|
| Reset clears data | `00000000` | `00000000` | PASS |
| Load captures `A5` | `000000a5` | `000000a5` | PASS |
| Hold keeps `A5` | `000000a5` | `000000a5` | PASS |
| Reset clears valid | `00000000` | `00000000` | PASS |
| Set valid | `00000001` | `00000001` | PASS |
| Clear valid | `00000000` | `00000000` | PASS |
| Accept `A5` | `000001a5` | `000001a5` | PASS |
| Stall holds `A5` | `000001a5` | `000001a5` | PASS |
| Replace with `3C` | `0000013c` | `0000013c` | PASS |
| Consume empties buffer | `00000000` | `00000000` | PASS |
| Source sends `D2` | `000001d2` | `000001d2` | PASS |
| Sink consumes `D2` | `00000000` | `00000000` | PASS |

### Verification Caveat: NOT-Gate Checks

Some reported NOT-gate checks require further investigation. The transcript shows examples where the actual and expected values appear inconsistent with ordinary 32-bit bitwise inversion, despite the checks being marked PASS:

| Actual | Reported expected |
|---|---|
| `00000001` | `ffffffff` |
| `00000000` | `fffffffe` |

The transcript alone does not establish the cause. Review the expected-value expressions, operand widths, comparison logic, and pass/fail reporting in the testbench before treating these checks as independently validated.

**Verification status:** 64 checks reported passing; NOT-gate checker correctness remains to be confirmed.

Recommended additional tests:

- Reset assertion and deassertion.
- Prolonged backpressure.
- Repeated input acceptance and output consumption.
- Simultaneous input and output activity.
- Data stability during stalls.
- Valid-state behavior for every legal handshake condition.
- Correctness of every testbench comparison.

---

## 7. Cadence Genus Synthesis Results

| Metric | Reported value |
|---|---|
| Top module | `top_valid_ready` |
| Synthesis tool | Cadence Genus 21.14-s082_1 |
| Technology library | `tsmc18` |
| Operating condition | `slow (balanced_tree)` |
| Wireload mode | `enclosed` |
| Area mode | `timing library` |
| Standard-cell instances | 34 |
| Total reported area | 798.336 library area units |

These are synthesis-stage results. The area unit has not been confirmed as µm², and physical-design closure has not been established.

---

## 8. Standard-Cell Mapping and Area Analysis

### Cell Breakdown

| Standard cell | Instances | Reported area |
|---|---:|---:|
| `DFFHQX1` | 9 | 479.002 |
| `AOI22X1` | 8 | 133.056 |
| `NOR2XL` | 8 | 79.834 |
| `AND2X2` | 2 | 26.611 |
| `INVX1` | 2 | 13.306 |
| `NAND3BX1` | 1 | 16.632 |
| `NOR2BX1` | 1 | 13.306 |
| `OAI21XL` | 1 | 13.306 |
| `OR2X2` | 1 | 13.306 |
| `NOR2X1` | 1 | 9.979 |
| **Total** | **34** | **798.336** |

### Area Distribution

| Category | Instances | Area | Reported share |
|---|---:|---:|---:|
| Sequential | 9 | 479.002 | 60.0% |
| Inverter | 2 | 13.306 | 1.7% |
| Logic | 23 | 306.029 | 38.3% |
| Physical cells | 0 | 0.000 | 0.0% |
| **Total** | **34** | **798.336** | **100.0%** |

### Observations

- Sequential cells account for 60.0% of the reported cell area.
- The nine `DFFHQX1` instances form the largest area category.
- `AOI22X1` and `NOR2XL` are the largest combinational cell groups by instance count.
- The `u_data_register` hierarchy accounts for 645.322 area units, approximately 80.83% of the total.
- Hierarchy area includes the mapped cells attributed to that hierarchy; it should not be interpreted as flip-flop area alone.

### Area Optimization Plan

1. Inspect the RTL and mapped netlist for `u_data_register`.
2. Confirm the required data width and storage behavior.
3. Check whether redundant logic can be removed without changing functionality.
4. Review ready and handshake logic before modifying control conditions.
5. Run functional regression after every RTL modification.
6. Compare synthesis reports under consistent constraints and library settings.

---

## 9. Hierarchical Area Analysis

| Hierarchy block | Cell count | Reported area | Approximate share |
|---|---:|---:|---:|
| `u_data_register` | 25 | 645.322 | 80.83% |
| `u_handshake` | 2 | 26.611 | 3.33% |
| `u_ready_logic` | 2 | 19.958 | 2.50% |
| `u_valid_register` | 4 | 93.139 | 11.67% |
| **Top-level total** | **34** | **798.336** | **100% approximately** |

The data-register hierarchy is the largest reported area contributor. It is a logical starting point for investigation, but optimization should be guided by the RTL, timing requirements, and required buffer behavior.

---

## 10. Power Analysis

The supplied report describes power for `/top_valid_ready`, using activity frame `/stim#0/frame#0`.

### Power by Category

| Category | Reported power (W) | Reported power (µW) | Share |
|---|---:|---:|---:|
| Register | `5.66854e-05` | 56.6854 | 71.52% |
| Logic | `1.57260e-05` | 15.7260 | 19.84% |
| Clock | `6.84968e-06` | 6.84968 | 8.64% |
| **Total** | **`7.92611e-05`** | **79.2611** | **100%** |

### Power Components

| Component | Reported power | Share |
|---|---:|---:|
| Internal | 63.2657 µW | 79.82% |
| Switching | 15.9709 µW | 20.15% |
| Leakage | 0.0245062 µW | 0.03% |
| **Total** | **79.2611 µW** | **100% approximately** |

### Interpretation

- Register-category power is the largest reported category at 71.52%.
- Internal power is the largest reported component at 79.82%.
- Switching power depends on signal activity and effective capacitance.
- The clock category contributes 6.84968 µW.
- The result is an activity-based estimate, not a measurement of fabricated silicon.

For meaningful comparisons, keep stimulus, clock definitions, activity annotation, operating conditions, and analysis settings consistent. The supplied report does not establish extracted post-route parasitics.

---

## 11. Timing Analysis

The supplied Genus timing report identifies one setup path from `sink_ready` to a data-register input.

### Path Summary

| Timing item | Reported value |
|---|---|
| Path status | `MET` |
| Path group | `clk` |
| Startpoint | `sink_ready` |
| Endpoint | `u_buffer/u_data_register/data_out_reg[7]/D` |
| Capture clock edge | 10000 ps |
| Input delay | 1000 ps |
| Setup time | 323 ps |
| Clock uncertainty | 1000 ps |
| Data-path delay | 890 ps |
| Required time | 8677 ps |
| Reported slack | **6787 ps (6.787 ns)** |

### Reported Combinational Path

```text
sink_ready
    |
    v
  OR2X2
    |
    v
  AND2X2
    |
    v
   INVX1
    |
    v
  AOI22X1
    |
    v
  NOR2XL
    |
    v
data_out_reg[7]/D
```

### Slack Calculation

Required time:

\[
T_{\text{required}} = 10000 - 323 - 1000 = 8677\text{ ps}
\]

Arrival time:

\[
T_{\text{arrival}} = 1000 + 890 = 1890\text{ ps}
\]

Slack:

\[
\text{Slack} = 8677 - 1890 = 6787\text{ ps}
\]

\[
\boxed{\text{Slack} = +6.787\text{ ns}}
\]

The calculation matches the reported slack.

### Timing Interpretation

- The specific reported setup path is marked `MET`.
- Its reported slack is +6.787 ns.
- The data-path delay of 0.890 ns is not the same as setup slack.
- One passing path does not establish global timing closure.
- A complete timing summary is required to assess all relevant setup and hold paths.
- The reported wireload settings do not constitute post-route timing evidence.

---

## 12. Combined PPA Snapshot

| Metric | Reported result | Qualification |
|---|---|---|
| Functional simulation | 64 pass / 0 fail reported | NOT-gate checker requires review |
| Simulation completion | 157 ns | `$finish` reported |
| Standard-cell instances | 34 | Synthesis report |
| Cell area | 798.336 area units | Unit not confirmed as µm² |
| Estimated total power | 79.2611 µW | Activity-frame-based estimate |
| Largest hierarchy | `u_data_register` | 645.322 area units |
| Largest power category | Register | 56.6854 µW |
| Setup-path slack | +6.787 ns | One reported path |
| Overall timing closure | Not established | Full timing evidence required |
| Post-route PPA closure | Not established | Physical implementation evidence unavailable |

---

## 13. Recommended Validation Workflow

1. **Review the testbench:** Investigate the inconsistent NOT-gate expected values and comparison logic.
2. **Confirm functionality:** Re-run reset, load, hold, stall, replacement, and consumption tests.
3. **Inspect the RTL:** Verify data width, valid-state updates, and handshake conditions.
4. **Review synthesis mapping:** Identify the cells contributing to the data-register hierarchy area.
5. **Inspect complete timing reports:** Check path coverage, constraints, setup, and hold.
6. **Validate power inputs:** Confirm the activity source and analysis assumptions.
7. **Re-run the baseline:** Preserve reports and logs before optimization.
8. **Optimize incrementally:** Change one item at a time and repeat functional regression.
9. **Compare PPA consistently:** Use the same library, constraints, and tool settings.
10. **Document evidence:** Distinguish synthesis estimates from placed-and-routed results.

Do not optimize area or power at the expense of functional correctness.

---

## 14. Suggested Repository Structure

```text
day26-valid-ready-buffer-verilog-genus/
├── README.md
├── rtl/
│   ├── top_valid_ready.v
│   ├── valid_ready_buffer.v
│   ├── data_register.v
│   ├── valid_register.v
│   ├── handshake_logic.v
│   ├── ready_logic.v
│   ├── and_gate.v
│   ├── and_gate_2.v
│   └── or_gate.v
├── tb/
│   └── day26_tb.v
├── sim/
│   ├── simulation.log
│   └── waves.shm/
├── genus/
│   ├── constraints_top.sdc
│   ├── mapped_netlist.v
│   ├── synthesis.log
│   └── reports/
│       ├── hierarchy.rpt
│       ├── area.rpt
│       ├── power.rpt
│       └── timing.rpt
└── docs/
    └── ppa_analysis.md
```

> This is a suggested structure. It does not imply that every listed file exists in the current repository. Adjust filenames to match the actual project.

---

## 15. Industry Relevance

This project demonstrates practical exposure to:

- Synthesizable Verilog RTL.
- Valid-ready interface concepts.
- Data storage and control logic.
- Self-checking functional verification.
- Cadence NCSim simulation.
- Cadence Genus technology mapping.
- Standard-cell area analysis.
- Activity-based power estimation.
- Setup timing and slack calculations.
- RTL optimization and regression testing.
- Technical documentation and PPA reporting.

These concepts are relevant to entry-level RTL Design, ASIC Design, FPGA Design, and Design Verification roles.

---

## 16. Interview Questions

1. What is a valid-ready interface?
2. When does a valid-ready transfer occur?
3. What is backpressure?
4. How should data behave when `valid = 1` and `ready = 0`?
5. What is the purpose of a data register?
6. Why must valid state and data storage remain consistent?
7. What is the difference between combinational and sequential logic?
8. How do reset, load, and hold affect a register?
9. What is technology mapping?
10. What is the difference between hierarchy area and standard-cell area?
11. What are internal, switching, and leakage power?
12. What is a setup timing check?
13. How is setup slack calculated?
14. Why is data-path delay different from setup slack?
15. Why does one `MET` path not prove global timing closure?
16. Why should a self-checking testbench itself be validated?
17. How would you test prolonged backpressure?
18. What evidence is needed to claim post-route PPA closure?

---

## 17. Project Status

| Stage | Status |
|---|---|
| Functional simulation | 64 pass / 0 fail reported |
| NOT-gate checker review | Pending |
| Simulation completion | 157 ns |
| Hierarchy report | Reviewed |
| Standard-cell area report | Reviewed |
| Power report | Reviewed |
| One setup timing path | `MET`, +6.787 ns slack |
| Full setup/hold timing closure | Not established |
| Post-route physical implementation | Not established |
| Final PPA closure | Pending further validation |

---

## 18. Author

**Omkar Kalmesh Hadapad**  
Electronics and Communication Engineering

Digital VLSI | Verilog RTL | Functional Verification | Cadence Genus

---

<p align="center">
  <b>Day 26 — Valid-Ready Buffer Design, Verification and Synthesis Analysis</b>
</p>
