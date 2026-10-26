# Embedded Systems Laboratory — 8051

Laboratory reports for **EC39202: Embedded Systems Laboratory**, Department of Electronics and Electrical Communication Engineering, IIT Kharagpur.

The work covers 8051 assembly programming: array algorithms in external memory, memory-mapped combinational logic with LED and LDR interfacing, and an interrupt-driven real-time clock with stopwatch. Each experiment directory contains the original report and a technical summary.

## Table of Contents

- [Overview](#overview)
- [Experiment Index](#experiment-index)
- [Concepts Covered](#concepts-covered)
- [Tools and Hardware](#tools-and-hardware)
- [Repository Structure](#repository-structure)
- [Viewing the Reports](#viewing-the-reports)
- [Source Code Availability](#source-code-availability)
- [Academic Context and Attribution](#academic-context-and-attribution)

## Overview

| Item | Detail |
|------|--------|
| Course | EC39202 — Embedded Systems Laboratory |
| Institution | IIT Kharagpur, Department of E&ECE |
| Target device | Intel 80C51BH (8051 family) |
| Language | 8051 assembly |
| Reports | 3 experiments, February–April 2026 |

The experiments progress from pure software algorithms on the 8051 to hardware interfacing (LEDs, bus transceivers, an LDR) and finally to a multi-peripheral, interrupt-driven system using the 8255 PPI and multiplexed seven-segment displays.

## Experiment Index

| # | Experiment | Topics | Report |
|---|------------|--------|--------|
| 01 | [Sorting, searching, polynomial evaluation and substring matching](embedded-systems-lab/experiment-01-8051-algorithms/) | Bubble sort, binary search, Horner evaluation, substring search, external RAM addressing | [PDF](embedded-systems-lab/experiment-01-8051-algorithms/report.pdf) |
| 02 | [Interfacing and control of LEDs and combinational logic](embedded-systems-lab/experiment-02-led-combinational-logic/) | Port I/O, 74245 bus driver, truth-table logic in external memory, LDR mode switching | [PDF](embedded-systems-lab/experiment-02-led-combinational-logic/report.pdf) |
| 03 | [Real-time clock with stopwatch](embedded-systems-lab/experiment-03-real-time-clock-stopwatch/) | 8255 PPI, 7-segment multiplexing, Timer-0 interrupts, key debouncing | [PDF](embedded-systems-lab/experiment-03-real-time-clock-stopwatch/report.pdf) |

## Concepts Covered

- **External memory access** with `MOVX` and the `DPTR` register, including pointer arithmetic with `INC DPTR` and `DEC DPL`.
- **Classical algorithms in assembly** — bubble sort, binary search, Horner-form polynomial evaluation with carry propagation, and a two-index substring search.
- **Memory-mapped combinational logic** — evaluating a four-input Boolean function by reading a truth table at `9000H`–`900FH` instead of encoding logic in branches.
- **Port I/O and current driving** — bit-level `SETB`/`CLR` on Port 1, and the use of a 74245 octal bus transceiver as a buffer and level regenerator.
- **Polling and software delay loops** — nested `DJNZ` loops for human-visible timing, and their limits for calibrated delays.
- **Peripheral interfacing** — 8255 PPI in Mode 0, 74373 address latch, common-cathode 7-segment displays, multiplexed scanning.
- **Interrupt-driven timekeeping** — Timer-0 periodic interrupts maintaining a real-time clock and an independent stopwatch concurrently.

## Tools and Hardware

Documented in the reports:

| Category | Items |
|----------|-------|
| Software | Keil µVision, Win51 |
| Microcontroller | Intel 80C51BH trainer kit |
| Peripherals | 8255 PPI, 74245 bus transceivers, 74373 latch |
| Displays | Common-cathode 7-segment modules (1, 2 and 6 digits across the parts) |
| Other | LEDs, LDR with bias resistor, push-buttons, breadboard, 26-pin FRC cable, +5 V supply |

## Repository Structure

```text
embedded-systems-lab/
├── README.md
├── .gitignore
└── embedded-systems-lab/
    ├── README.md
    ├── experiment-01-8051-algorithms/
    │   ├── README.md
    │   └── report.pdf
    ├── experiment-02-led-combinational-logic/
    │   ├── README.md
    │   └── report.pdf
    └── experiment-03-real-time-clock-stopwatch/
        ├── README.md
        ├── report.pdf
        └── src/
            ├── exp03_part_b_multiplexed_display.a51
            └── exp03_part_c_clock_stopwatch.a51
```

## Viewing the Reports

The PDFs are the original submitted reports, stored unmodified. Click any `report.pdf` link above to view it in the browser, or clone the repository and open it locally:

```bash
git clone https://github.com/Raj-Jai/embedded-systems-lab.git
cd embedded-systems-lab
xdg-open embedded-systems-lab/experiment-01-8051-algorithms/report.pdf
```

Each experiment README summarises the objective, hardware mapping, algorithm and results, and refers to specific figures by number in the PDF. The reports contain the flowcharts, circuit diagrams, assembly listings and result screenshots; images are not duplicated outside the PDFs because the PDF is the authoritative record.

## Source Code Availability

Three kinds of code appear in this repository, and they are not equivalent:

| Code | Status | Location |
|------|--------|----------|
| Experiment 3, parts (b) and (c) | Original `.a51` source files from the lab machine | `experiment-03-.../src/` |
| Experiment 1, all parts | Only inside the report as typeset listings | `experiment-01-.../report.pdf` |
| Experiment 2, all parts | Only inside the report as typeset listings | `experiment-02-.../report.pdf` |
| Experiment 3, part (a) | Only inside the report as a typeset listing | `experiment-03-.../report.pdf` |

No source file has been reconstructed from a PDF. Code that exists only in a report is referenced as a report listing, never presented as an original source file.

## Academic Context and Attribution

These are academic laboratory exercises completed for EC39202 at IIT Kharagpur, not independent projects. All three reports are joint work by:

- **Soumadipta Majumder** (23EC30055)
- **Jai Raj** (23EC10031)

Both were members of **Group 5**. The reports contain both authors' individual discussion sections; those attributions are preserved in the PDFs.

The reports, diagrams and results belong to the authors and the course. No open-source license is applied to this repository because the material is shared coursework and licensing it would require the co-author's agreement. The READMEs are a factual record of the experiments, not a claim of sole authorship.
