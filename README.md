# Day 26 --- Valid-Ready Buffer Design and Verification

```{=html}
<p align="center">
```
**Digital VLSI • Verilog RTL • Valid-Ready Handshaking • Cadence Genus**
```{=html}
</p>
```
```{=html}
<p align="center">
```
`Specification → RTL → Testbench → Simulation → Synthesis → Area → Power → Timing → PPA Review`
```{=html}
</p>
```
```{=html}
<p align="center">
```
`<img alt="Project" src="https://img.shields.io/badge/Project-Valid--Ready%20Buffer-blue">`{=html}
`<img alt="HDL" src="https://img.shields.io/badge/HDL-Verilog-8A2BE2">`{=html}
`<img alt="Synthesis" src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange">`{=html}
`<img alt="Verification" src="https://img.shields.io/badge/Verification-64%20Checks%20Reported-success">`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

## 1. Project Information

  -----------------------------------------------------------------------
  Parameter                           Details
  ----------------------------------- -----------------------------------
  **Project**                         Valid-Ready Buffer Design and
                                      Verification

  **Author**                          Omkar Kalmesh Hadapad

  **Domain**                          Digital VLSI / RTL Design /
                                      Functional Verification

  **Design Type**                     Valid-ready buffer with data and
                                      valid-state registers

  **HDL**                             Verilog HDL

  **Simulation Tool**                 Cadence NCSim

  **Synthesis Tool**                  Cadence Genus 21.14-s082_1

  **Technology Library**              `tsmc18`

  **Top Module**                      `top_valid_ready`

  **Main Buffer Module**              `valid_ready_buffer`

  **Reported Functional Checks**      64 reported pass, 0 reported fail

  **Simulation Completion**           `$finish` at 157 ns

  **Synthesis Cell Count**            34 standard-cell instances

  **Reported Cell Area**              798.336 library area units

  **Estimated Total Power**           79.2611 µW

  **Reported Setup Path Slack**       +6787 ps (6.787 ns)

  **Physical Design Status**          Post-route PPA closure not
                                      established
  -----------------------------------------------------------------------

> **Measurement note:** The area unit has not been confirmed as µm². The
> power report uses activity frame `/stim#0/frame#0`. The timing result
> applies to the specific reported setup path; it does not prove that
> every path is constrained or meets timing. No post-route or
> extracted-parasitic results were supplied.

------------------------------------------------------------------------

## 2. Project Overview

This project implements and verifies a valid-ready buffer design. The
reported hierarchy includes a data register, valid register, handshake
logic, and ready logic.

The NCSim transcript reports 64 checks passed and zero failures, with
simulation finishing at 157 ns. The tests cover gate-level logic, ready
equations, handshake behavior, data-register reset/load/hold behavior,
valid-register behavior, buffer reset and input acceptance, stall/hold
behavior, data replacement and consumption, and top-level integration.

The synthesis reports provide standard-cell mapping, hierarchy, power,
and a setup timing path for `top_valid_ready`.

The project covers:

-   Valid-ready interface fundamentals.
-   Data and valid-state storage.
-   Ready and handshake logic.
-   Reset, load, and hold behavior.
-   Buffer stall, replacement, and consumption scenarios.
-   Self-checking Verilog testbench execution.
-   Cadence NCSim simulation.
-   Cadence Genus standard-cell synthesis.
-   Cell area and hierarchy analysis.
-   Internal, switching, and leakage power interpretation.
-   Setup timing report interpretation.
-   Testbench checker validation and PPA evidence limitations.

------------------------------------------------------------------------

## 3. Objectives

1.  Understand valid-ready handshaking.
2.  Understand data storage and valid-state tracking.
3.  Verify reset behavior of data and valid registers.
4.  Verify load and hold behavior.
5.  Verify input acceptance and backpressure/stall behavior.
6.  Verify data replacement and consumption.
7.  Verify top-level integration.
8.  Run a self-checking Verilog testbench in Cadence NCSim.
9.  Inspect the simulation log and waveform database.
10. Synthesize the design using Cadence Genus.
11. Analyze standard-cell count and area distribution.
12. Interpret register, logic, and clock-category power.
13. Calculate and interpret the reported setup slack.
14. Identify verification and timing-analysis limitations.
15. Document a reproducible baseline before optimization.

------------------------------------------------------------------------

## 4. Reported Architecture

### Hierarchy

``` text
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

### Hierarchy block summary

  Instance             Module                 Function indicated by name
  -------------------- ---------------------- ------------------------------
  `u_buffer`           `valid_ready_buffer`   Main valid-ready buffer
  `u_data_register`    `data_register`        Data storage
  `u_handshake`        `handshake_logic`      Input/output handshake logic
  `u_input_and`        `and_gate`             Input-side AND logic
  `u_output_and`       `and_gate_2`           Output-side AND logic
  `u_ready_logic`      `ready_logic`          Ready-generation logic
  `u_or`               `or_gate`              OR logic inside ready logic
  `u_valid_register`   `valid_register`       Valid-state storage

This table describes the reported hierarchy and names. Exact Boolean
equations and signal connectivity must be confirmed from the RTL.

### Conceptual valid-ready operation

In a conventional synchronous valid-ready interface, a transfer occurs
at the active sampling edge when both `valid` and `ready` are asserted:

``` text
transfer = valid AND ready
```

-   `valid` indicates that the producer is presenting valid data.
-   `ready` indicates that the consumer can accept data.
-   When both are asserted at the sampling edge, a transfer occurs.
-   If the buffer cannot accept new data, the interface must follow its
    specified backpressure and data-hold behavior.

The exact protocol behavior should be confirmed against the design RTL
and testbench.

------------------------------------------------------------------------

## 5. Functional Verification

### Reported NCSim results

  Task        Test area                       Checks Reported result
  ----------- ----------------------------- -------- ----------------------
  1           Gate-level logic                    12 PASS
  2           Ready logic                          4 PASS
  3           Handshake logic                     36 PASS
  4           Data-register reset                  1 PASS
  5           Data-register load and hold          2 PASS
  6           Valid register                       3 PASS
  7           Buffer reset and input               2 PASS
  8           Buffer stall and hold                2 PASS
  9           Replace and consume data             3 PASS
  10          Top-module integration               3 PASS
  **Total**                                   **64** **64 reported pass**

### Selected reported scenarios

  Scenario                        Actual     Expected Reported result
  ------------------------- ------------ ------------ -----------------
  Reset clears data           `00000000`   `00000000` PASS
  Load captures `A5`          `000000a5`   `000000a5` PASS
  Hold keeps `A5`             `000000a5`   `000000a5` PASS
  Reset clears valid          `00000000`   `00000000` PASS
  Set valid                   `00000001`   `00000001` PASS
  Clear valid                 `00000000`   `00000000` PASS
  Accept `A5`                 `000001a5`   `000001a5` PASS
  Stall holds `A5`            `000001a5`   `000001a5` PASS
  Replacement stores `3C`     `0000013c`   `0000013c` PASS
  Consume empties buffer      `00000000`   `00000000` PASS
  Source sends `D2`           `000001d2`   `000001d2` PASS
  Sink consumes `D2`          `00000000`   `00000000` PASS

### Verification summary

  Metric                           Reported result
  --------------------------- --------------------
  Total checks                              **64**
  Failed checks                              **0**
  Simulation completion                 **157 ns**
  Termination                            `$finish`
  Overall testbench summary     `ALL TESTS PASSED`

### Verification caveat: NOT-gate expected values

The transcript reports some NOT-gate checks as passing even though the
displayed actual and expected values appear inconsistent with ordinary
32-bit bitwise inversion. For example, actual `00000001` is shown
against expected `ffffffff`, and actual `00000000` against expected
`fffffffe`.

These lines warrant inspection of the testbench's expected-value
expressions, operand widths, and comparison/reporting logic. The log
alone does not establish the cause. Therefore, the summary should be
described as **64 checks reported passing**, while independent
validation of those NOT-gate checks remains pending until the checker is
reviewed.

For stronger verification, also test reset transitions, prolonged
backpressure, repeated replacement/consumption, and all legal
combinations of valid and ready.

------------------------------------------------------------------------

## 6. Genus Synthesis Results

The supplied Cadence Genus reports provide the following synthesis
results.

  Metric                                       Reported value
  -------------------------- --------------------------------
  Top module                                `top_valid_ready`
  Standard-cell instances                              **34**
  Total reported cell area     **798.336 library area units**
  Technology library                                 `tsmc18`
  Operating condition                  `slow (balanced_tree)`
  Wireload mode                                    `enclosed`
  Area mode                                  `timing library`
  Synthesis tool                   Cadence Genus 21.14-s082_1

These are synthesis-stage results. The physical area unit is not
confirmed as µm², and post-placement/post-route closure has not been
demonstrated.

------------------------------------------------------------------------

## 7. Standard-Cell Mapping Analysis

### Reported cell breakdown

  Standard cell     Instances   Reported area
  --------------- ----------- ---------------
  `DFFHQX1`                 9         479.002
  `AOI22X1`                 8         133.056
  `NOR2XL`                  8          79.834
  `AND2X2`                  2          26.611
  `INVX1`                   2          13.306
  `NAND3BX1`                1          16.632
  `NOR2BX1`                 1          13.306
  `OAI21XL`                 1          13.306
  `OR2X2`                   1          13.306
  `NOR2X1`                  1           9.979
  **Total**            **34**     **798.336**

### Area distribution by category

  Category           Instances          Area   Reported share
  ---------------- ----------- ------------- ----------------
  Sequential                 9       479.002            60.0%
  Inverter                   2        13.306             1.7%
  Logic                     23       306.029            38.3%
  Physical cells             0         0.000             0.0%
  **Total**             **34**   **798.336**       **100.0%**

### Interpretation

-   Sequential cells account for 60.0% of the reported cell area.
-   The nine `DFFHQX1` cells are the largest area category.
-   `AOI22X1` and `NOR2XL` are the largest individual combinational cell
    groups by instance count.
-   The hierarchy report attributes 645.322 area units to
    `u_data_register`. This can include both storage cells and
    combinational logic; it should not be equated with flip-flop area
    alone.
-   Cell names and counts do not by themselves prove the exact RTL
    function of each mapped cell.

------------------------------------------------------------------------

## 8. Hierarchical Area Analysis

### Reported hierarchy

  Hierarchy block         Cell count   Reported area        Approximate share
  --------------------- ------------ --------------- ------------------------
  `u_data_register`               25         645.322                   80.83%
  `u_handshake`                    2          26.611                    3.33%
  `u_ready_logic`                  2          19.958                    2.50%
  `u_valid_register`               4          93.139                   11.67%
  **Top-level total**         **34**     **798.336**   **100% approximately**

Percentages may not sum exactly to 100% because of rounding.

### Main observation

The data-register hierarchy is the largest reported area contributor,
accounting for approximately 80.83% of total area. It is the first block
to inspect for area optimization, but any change must preserve the
required data-storage and stall/hold behavior.

### Optimization priorities

1.  Inspect the RTL and mapped cells inside `u_data_register`.
2.  Confirm that the implemented register width and hold behavior match
    the specification.
3.  Inspect the ready and handshake paths before changing control logic.
4.  Preserve reset and valid-ready protocol behavior.
5.  Re-run the same testbench and synthesis flow after each RTL change.
6.  Compare area results only when library, constraints, and synthesis
    settings are consistent.

------------------------------------------------------------------------

## 9. Power Analysis

The supplied power report is for:

``` text
Instance: /top_valid_ready
Power Unit: W
PDB Frame: /stim#0/frame#0
```

### Power by category

  Category            Total power (W)   Total power (µW)      Share
  --------------- ------------------- ------------------ ----------
  Register              `5.66854e-05`            56.6854     71.52%
  Logic                 `1.57260e-05`            15.7260     19.84%
  Clock                 `6.84968e-06`            6.84968      8.64%
  Memory                            0                  0         0%
  Latch                             0                  0         0%
  Bbox, pad, PM                     0                  0         0%
  **Total**         **`7.92611e-05`**        **79.2611**   **100%**

### Internal, switching and leakage power

  Component     Reported power                    Share
  ----------- ---------------- ------------------------
  Internal          63.2657 µW                   79.82%
  Switching         15.9709 µW                   20.15%
  Leakage         0.0245062 µW                    0.03%
  **Total**     **79.2611 µW**   **100% approximately**

### Interpretation

-   Register-category power dominates the estimate at 71.52%.
-   Internal power is the largest power component at 79.82%.
-   Switching power depends on signal activity and effective
    capacitance.
-   The clock category contributes 6.84968 µW in the supplied report.
-   These values are an activity-based estimate, not measured silicon
    power.

Before comparing designs, use consistent stimulus, clock definitions,
activity annotation, operating conditions, and analysis settings. The
supplied report does not establish extracted post-route parasitics.

------------------------------------------------------------------------

## 10. Timing Analysis

The supplied Genus timing report contains the following setup path.

### Reported path summary

  Timing item          Reported value
  -------------------- ----------------------------------------------
  Path status          `MET`
  Path group           `clk`
  Startpoint           `sink_ready`
  Endpoint             `u_buffer/u_data_register/data_out_reg[7]/D`
  Capture clock edge   10000 ps
  Input delay          1000 ps
  Setup time           323 ps
  Clock uncertainty    1000 ps
  Data-path delay      890 ps
  Required time        8677 ps
  Reported slack       **6787 ps (6.787 ns)**

### Reported combinational path

``` text
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

### Slack calculation

Required time:

\[ T\_{`\text{required}`{=tex}}=10000-323-1000=8677`\text{ ps}`{=tex} \]

Arrival time:

\[ T\_{`\text{arrival}`{=tex}}=1000+890=1890`\text{ ps}`{=tex} \]

Slack:

\[ `\text{Slack}`{=tex}=8677-1890=`\boxed{6787\text{ ps}}`{=tex} \]

The calculation matches the reported slack.

### Timing interpretation

-   The specific reported setup path is marked `MET` with positive
    slack.
-   The path is an input-to-register path from `sink_ready` to a
    data-register D pin.
-   The 0.890 ns data-path delay is not the same as setup slack.
-   This result does not prove that every path meets timing.
-   A complete timing summary is needed to establish overall setup/hold
    status and confirm that all relevant paths are constrained.
-   The synthesis report uses `slow (balanced_tree)` and `enclosed`
    wireload settings; it is not post-route timing evidence.

------------------------------------------------------------------------

## 11. Combined PPA Snapshot

  -------------------------------------------------------------------------
  Metric                                      Result Qualification
  --------------------- ---------------------------- ----------------------
  Functional simulation    64 pass / 0 fail reported NOT-gate checker needs
                                                     review

  Simulation completion                       157 ns `$finish` shown

  Standard-cell                                   34 Genus synthesis report
  instances                                          

  Reported cell area              798.336 area units Unit not confirmed as
                                                     µm²

  Estimated total power                   79.2611 µW Activity-frame-based
                                                     estimate

  Largest hierarchy                `u_data_register` 645.322 area units
  block                                              

  Largest power                             Register 56.6854 µW
  category                                           

  Reported setup path                      +6.787 ns One path only
  slack                                              

  Overall timing                     Not established Full timing summary
  closure                                            required

  Post-route PPA                     Not established Physical
  closure                                            implementation
                                                     evidence not supplied
  -------------------------------------------------------------------------

------------------------------------------------------------------------

## 12. Recommended Optimization and Validation Plan

  -----------------------------------------------------------------------
  Priority                Action                  Reason
  ----------------------- ----------------------- -----------------------
  1                       Review NOT-gate         Some displayed
                          expected-value and      actual/expected pairs
                          comparison logic        appear inconsistent
                                                  despite PASS

  2                       Review                  It dominates reported
                          `u_data_register` RTL   area
                          and mapped netlist      

  3                       Review valid-ready      Must remain correct
                          stall and hold behavior under backpressure

  4                       Inspect the complete    One passing path does
                          timing summary          not establish global
                                                  timing closure

  5                       Validate power-analysis Enables meaningful
                          activity and settings   power comparisons

  6                       Re-run functional       Protects behavior
                          simulation after RTL    against regressions
                          changes                 

  7                       Re-run Genus area,      Creates a consistent
                          power, and timing       before/after PPA
                          reports                 comparison
  -----------------------------------------------------------------------

Do not change RTL solely to reduce area or power before identifying the
functional and timing consequences.

------------------------------------------------------------------------

## 13. Suggested Repository Structure

``` text
day26-valid-ready-buffer/
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
│   ├── reports/
│   │   ├── hierarchy.rpt
│   │   ├── area.rpt
│   │   ├── power.rpt
│   │   └── timing.rpt
│   ├── mapped_netlist.v
│   └── synthesis.log
└── docs/
    └── ppa_analysis.md
```

This is a suggested layout, not confirmation that all listed files
exist. Rename entries to match the actual repository contents.

------------------------------------------------------------------------

## 14. Industry Relevance

This project demonstrates concepts relevant to:

-   Synthesizable Verilog RTL.
-   Valid-ready interface design.
-   Data storage and control logic.
-   Functional verification and self-checking testbenches.
-   Cadence NCSim simulation.
-   Cadence Genus technology mapping.
-   Standard-cell area analysis.
-   Power estimation and activity interpretation.
-   Setup timing and slack calculations.
-   RTL optimization with functional regression testing.
-   Engineering documentation and PPA reporting.

These concepts are relevant to entry-level RTL Design, ASIC Design, FPGA
Design, and Design Verification roles.

------------------------------------------------------------------------

## 15. Interview Questions

1.  What is a valid-ready interface?
2.  Under what condition does a valid-ready transfer occur?
3.  What is backpressure?
4.  What should happen to data while `valid` is asserted and `ready` is
    deasserted?
5.  What is the purpose of a data register in a buffer?
6.  Why are data and valid state often updated together?
7.  What is the difference between combinational and sequential logic?
8.  How do reset, load, and hold conditions affect a register?
9.  What does technology mapping do?
10. What is the difference between hierarchy area and standard-cell
    area?
11. What are internal, switching, and leakage power?
12. What is a setup check?
13. How is setup slack calculated?
14. Why is data-path delay different from setup slack?
15. Does one `MET` path prove overall timing closure?
16. Why must a self-checking testbench be checked for correctness?
17. How would you test long-duration backpressure?
18. What additional evidence is needed to claim post-route PPA closure?

------------------------------------------------------------------------

## 16. Project Status

  Stage                                Status
  ------------------------------------ ------------------------------------------
  Functional simulation                64 pass / 0 fail reported
  Testbench checker review             NOT-gate expected values need inspection
  Simulation completion                Completed at 157 ns
  Hierarchy report                     Reviewed
  Standard-cell area report            Reviewed
  Power report                         Reviewed
  One setup timing path                `MET`, +6.787 ns slack
  Full setup/hold timing closure       Not established
  Post-route physical implementation   Not established
  Final PPA closure                    Pending further validation

------------------------------------------------------------------------

## 17. Author

**Omkar Kalmesh Hadapad**\
Electronics and Communication Engineering

Digital VLSI • Verilog RTL • Functional Verification • Cadence Genus

------------------------------------------------------------------------

```{=html}
<p align="center">
```
**Day 26 --- Valid-Ready Buffer Design, Verification and Synthesis
Analysis**
```{=html}
</p>
```
