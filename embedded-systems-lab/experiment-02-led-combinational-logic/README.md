# Experiment 2 — Interfacing and Control of LEDs and Combinational Logic using 8051

**Course:** EC39202 Embedded Systems Laboratory · **Date on report:** 3 March 2026 · **Group 5**

[Read the original report (PDF)](report.pdf)

## Objective

1. Glow a single LED.
2. Blink four LEDs sequentially, with roughly one second ON and one second OFF per LED.
3. Implement a four-input combinational logic evaluator: inputs `A` (MSB), `B`, `C`, `D` (LSB) are shown on four LEDs, and a fifth LED displays the function output read from a truth table in external memory at `9000H`–`900FH`.
4. Add LDR-based mode switching: covering the LDR makes all five LEDs blink; uncovering it restores normal truth-table scanning from `0000`.

> **Note on part labels.** The objective numbers the tasks 1–4, while the flowcharts and code listings label them (a)–(d) with a one-position offset: report §5 lists "(a) sequentially blink 4 LEDs", "(b) truth-table output" and "(c) LDR-triggered blink". This README uses the objective's numbering (a = single LED, b = sequential blink, c = truth table, d = LDR) and names the corresponding listing where relevant.

## Key Concepts

- Bit-level port control with `SETB`/`CLR` on Port 1, and whole-port writes with `MOV P1, A`.
- Current limiting and current sourcing: the 8051 port cannot drive LEDs directly at useful brightness, so a **74245 octal bus transceiver** is used as a buffer/driver.
- Memory-mapped combinational logic: instead of coding Boolean terms, the function is stored as 16 bytes and indexed by the input combination (`DPTR = 9000H + index`, read with `MOVX`).
- Polling an LDR input and switching between two operating modes at the top of the main loop.
- Software delay loops built from nested `DJNZ`.

## Hardware and Pin Mapping

| Signal | Pin / Address | Function |
|--------|---------------|----------|
| `P1.0` | Port 1 | Input LED for bit D (mapped bit 0) |
| `P1.1` | Port 1 | Input LED for bit C (mapped bit 1) |
| `P1.2` | Port 1 | Input LED for bit B (mapped bit 2) |
| `P1.3` | Port 1 | Input LED for bit A (mapped bit 3) |
| `P1.4` | Port 1 | Function output LED `F(A,B,C,D)` |
| `P1.6` | Port 1 | LDR status input (low when covered) |
| `9000H`–`900FH` | External RAM | Truth table, 16 entries of `00H`/`01H` |

Components documented in the report: 8051 trainer kit, breadboard and 26-pin FRC cable, IC 74245, five LEDs, current-limiting resistors (typically 220 Ω–1 kΩ), LDR with bias resistor, external DC supply and jumper wires.

Wiring notes from the report: Port 1 lines go to the 74245/breadboard nodes and then to the LEDs through series resistors; the LDR conditioning output feeds `P1.6`; the 8051 kit ground and the external supply ground are tied together.

## Implementation

**Sequential blink (b).** `P1.0`–`P1.3` are cleared, then each bit is set in turn, held by a delay subroutine, cleared, and delayed again. The delay is three nested `DJNZ` loops (`R2 = 20`, `R1 = 100`, `R0 = 255`).

**Truth-table scan (c).** `R3` holds the index `00H`–`0FH`. Its value is written to `P1` (so the low four bits drive the input LEDs), then `DPL = R3`, `DPH = 90H` and `MOVX A, @DPTR` fetches the entry. The entry is compared with `01H` using `CJNE`: equal sets `P1.4`, otherwise `P1.4` is cleared. The index increments after a delay and wraps back to `00H` after `0FH`.

**LDR mode (d).** At the top of every loop `JNB P1.6, BLINK` tests the LDR input. When it reads low (covered), the routine writes `FFH` to `P1` (all LEDs on), delays, writes `00H`, delays, resets `R3` to `00H` and re-enters the scan. This reset is what makes the behaviour deterministic after a blink episode.

## Figures and Results in the Report

| Content | Reference |
|---------|-----------|
| Sequential 4-LED blink flowchart | Report §2, part (b) |
| Truth-table scan with LDR mode flowchart | Report §2, part (c) |
| Circuit diagrams: single LED, 4-LED blink, truth-table mapping, LDR switching | Report §3 |
| Assembly: sequential blink | Listing (a), §5 |
| Assembly: truth-table output | Listing (b), §5 |
| Assembly: LDR-triggered blink | Listing (c), §5 |
| Hardware test photo and three demonstration videos | Report §6 ("Image 1", "Video 1–3", YouTube links) |

Observed behaviour as recorded: the four LEDs blink sequentially with a visible ON/OFF delay; in truth-table mode the input LEDs cycle from `0000` to `1111` and `P1.4` follows the memory contents; covering the LDR blinks all five LEDs and uncovering it restarts the scan at `0000`.

## Practical Findings

Both authors documented hardware-level issues, which are the most transferable part of this experiment:

- **LED current limiting.** Driving an LED without a series resistor risks thermal damage; the resistor was essential, not optional.
- **Port initialisation.** Writing values to Port 1 without first driving the pins to a known state left the LEDs stuck on; explicitly clearing the port bits first fixed it.
- **Drive strength and the 74245.** The transceiver sources the LED current from `VCC`, protecting the microcontroller and giving stable brightness.
- **LDR level conditioning.** The resistive divider only reached about **2.5 V** in the high state, which the 8051 did not reliably accept as a logic 1. The 74245's lower `VIH` (around 2.0 V) let it regenerate a full 5 V logic level, so the transceiver acted as a comparator stage as well as a driver.
- **Timing.** Software delay loops are adequate for visual demonstration but not for calibrated one-second timing, since their duration depends on the oscillator and instruction overhead.

## Hardware and Software

- 8051 trainer kit, 74245, LEDs, resistors, LDR, breadboard, external DC supply
- Keil µVision, Win51

## Source Code

**No `.a51` source files exist for this experiment.** The three assembly programs are available only as typeset listings inside the report PDF. No source file has been reconstructed from the PDF.
