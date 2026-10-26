# Experiment 3 — Real-Time Clock with Stopwatch

**Course:** EC39202 Embedded Systems Laboratory · **Date on report:** 3 April 2026 · **Group 5**

[Read the original report (PDF)](report.pdf)

## Objective

1. Interface common-cathode seven-segment displays to the 8051 trainer kit through an **8255 PPI** and **74245** line drivers.
2. Display digits `0`–`9` continuously on one display, about one second per digit.
3. Display the discontinuous sequence **00–06, 15–23, 29, 47–54** on two multiplexed displays, about 0.5 s per number.
4. Build a dual-mode system: a normal real-time clock and a stopwatch, both `hh-mm-ss`, selected by a mode switch.
5. Use a **timer-interrupt time base** so that the clock keeps running while the stopwatch is being used.

## Key Concepts

- **8255 PPI in Mode 0** as a port expander: Port A for segment data, Port B for digit selection, Port C for switches.
- **Seven-segment encoding** via a lookup table (`3FH`, `06H`, `5BH`, `4FH`, `66H`, `6DH`, `7DH`, `07H`, `7FH`, `6FH` for 0–9).
- **Time-division multiplexing**: shared segment lines, one common cathode enabled at a time, refreshed fast enough that persistence of vision shows a steady multi-digit number.
- **Timer-0 interrupts** as a periodic tick; the ISR counts ticks up to one second and updates registers, rather than the main loop polling for elapsed time.
- **Concurrent state machines**: a `RUN` flag lets the stopwatch advance or hold independently of the clock.
- **Active-low push-buttons with software debouncing**.

## Hardware and Address Map

| Address | Function |
|---------|----------|
| `0E800H` | 8255 Port A — segment data bus (a–g, dp) through a 74245 |
| `0E801H` | 8255 Port B — digit select / common-cathode enables through a second 74245 |
| `0E802H` | 8255 Port C — switch inputs (mode, start/reset, stop) |
| `0E803H` | 8255 control word register |
| `9000H`–`9002H` | Clock BCD values: hours, minutes, seconds |
| `9003H`–`9005H` | Stopwatch BCD values: hours, minutes, seconds |

Components documented: 8051 trainer kit, 8255 PPI, two 74245 transceivers, 74373 address latch, one/two/six common-cathode displays depending on the part, 220 Ω–470 Ω segment resistors, push-buttons for mode/start/stop, breadboard, FRC cable, +5 V supply.

Connection notes: segment lines are paralleled across displays with individual series resistors; each display's common cathode is driven separately for scanning; switches are active-low and debounced in software; all grounds are common.

## Implementation

**Part (a) — single display, 0–9.** The control register is written with `80H` (all ports output, Mode 0), then each digit's segment code is written to Port A in turn with a delay between writes, looping forever. The part (a) listing also contains a delay subroutine using three nested `DJNZ` loops (`R2 = 10`, `R1 = 200`, `R0 = 255`).

**Part (b) — two displays, custom sequence.** Port A carries segment data and Port B the digit enables. The number is split into tens and units, both mapped through the lookup table, and the two common cathodes are alternated rapidly; the displayed number is held for about 0.5 s before advancing. Because the sequence is not contiguous, the update uses explicit range transitions: `00–06 → 15–23 → 29 → 47–54 → 00`.

**Part (c) — clock and stopwatch.** The 8255, lookup table, timer and both register sets are initialised, then the main loop scans the debounced keys and refreshes the multiplexed display. A Timer-0 ISR runs on a fixed tick, accumulates ticks to one second, always advances the clock, and advances the stopwatch only when `RUN = 1`. Start resets the stopwatch to `00:00:00` and sets `RUN`; Stop clears `RUN`. In clock mode the stopwatch is hidden but keeps its state; in stopwatch mode the clock continues to be maintained by the ISR.

The part (c) source writes `89H` to the 8255 control register, which configures Port A and Port B as outputs and the Port C lines used by the keys as inputs.

## Figures and Results in the Report

| Content | Reference |
|---------|-----------|
| Part (a) flowchart: single display 0–9 | Report §2 |
| Part (b) flowchart: two-display sequence | Report §2 |
| Part (c) flowchart: clock with stopwatch | Report §2 |
| 8255/74245 single-display interface | Figure 1 |
| Two-display multiplexed interface | Figure 2 |
| Six-digit clock + stopwatch wiring with switches | Figure 3 |
| Part (a) assembly listing | Listing 1, §5 |
| Part (b) and (c) assembly listings | §5 |
| Demonstration videos | Report §6 (YouTube links) |

Recorded results: digits `0`–`9` displayed cyclically; the non-linear sequence shown correctly on two multiplexed displays; both clock and stopwatch functional, with start/stop and mode switching verified; and the normal clock continuing to update while in stopwatch mode, confirming concurrent interrupt-driven timekeeping.

## Practical Findings

- Lookup-table segment encoding and correct 8255 initialisation were the two prerequisites for a clean display; small delay mismatches produced visibly inconsistent transitions.
- In the multiplexed part, refresh rate traded directly against brightness and flicker, and the non-contiguous sequence forced explicit boundary handling instead of simple increment.
- The interrupt-driven design demonstrated why a periodic ISR is preferable to polling when several time-dependent tasks must run at once; debouncing was needed to avoid false mode/start/stop triggers.

## Source Code

Two **original** `.a51` files from the lab machine are included:

| File | Contents |
|------|----------|
| [`src/exp03_part_b_multiplexed_display.a51`](src/exp03_part_b_multiplexed_display.a51) | Two-display multiplexed sequence, Port B digit enables |
| [`src/exp03_part_c_clock_stopwatch.a51`](src/exp03_part_c_clock_stopwatch.a51) | Timer-0 ISR, clock and stopwatch registers, key scanning |

Part (a) exists only as a typeset listing in the report. No listing has been converted into a source file. A third file found alongside these two was a compiled object rather than readable source, so it is not included.
