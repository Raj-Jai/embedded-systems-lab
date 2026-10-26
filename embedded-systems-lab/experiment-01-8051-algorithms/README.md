# Experiment 1 — Sorting, Searching, Polynomial Evaluation and Substring Matching on 8051

**Course:** EC39202 Embedded Systems Laboratory · **Date on report:** 8 February 2026 · **Group 5**

[Read the original report (PDF)](report.pdf)

## Objective

Three independent programs, all operating on data in external RAM:

1. **(A) Sort and search** — sort 10 bytes stored from `9000H` into ascending order, then binary-search for a key. Store the element's **index** (not its address) at `9550H`, or `-1` if absent.
2. **(B) Polynomial evaluation** — given `n` at `9500H`, `x` at `9501H` and coefficients from `9502H`, evaluate
   `aₙxⁿ + aₙ₋₁xⁿ⁻¹ + … + a₁x + a₀`
   and store the result at `9550H`.
3. **(C) Substring matching** — determine whether a NULL-terminated string at `9000H` occurs inside a NULL-terminated string at `9200H`. Store the start index at `9500H`, or `-1` if not found.

## Key Concepts

- External RAM access through `MOVX @DPTR`, with `DPTR` used as a 16-bit pointer and `DEC DPL`/`INC DPTR` for backtracking over adjacent bytes.
- `CJNE` as a combined compare-and-branch, and reading the carry flag afterwards to distinguish "less than" from "greater than".
- Halving without a divide instruction: `ADD A, R1` followed by `CLR C` and `RR A` gives `⌊(low + high)/2⌋`.
- Nested `DJNZ` loops for pass counting and software delay.
- Multi-byte arithmetic: byte-wise multiply-accumulate with explicit carry propagation into a high byte.
- Two-index scanning with backtracking for substring search.

## Implementation

### (A) Bubble sort and binary search

The sort makes **10 passes over 9 adjacent pairs**, comparing `xRAM[DPTR]` with `xRAM[DPTR+1]` and swapping when the second byte is smaller. The loop bound is fixed at 10 passes and 9 comparisons per pass; there is no early-exit optimisation when a pass produces no swaps.

The search then runs over the sorted array with `low = 0`, `high = 9`, computing `mid`, loading `xRAM[9000H + mid]`, and moving `high = mid - 1` or `low = mid + 1`. On a match it writes `mid` to `9550H`; when `low > high` it writes `FFH`, which is the 8-bit representation of `-1`.

> **Note on the key address.** The problem statement says the search key is at `9500H`, but the pseudocode and the assembly listing load it from **internal RAM `27H`** (`MOV B, 27H`). Both are recorded here as they appear in the report; the code as printed uses `27H`.

### (B) Polynomial evaluation

The routine loads `n` and `x`, seeds the accumulator with the first coefficient, then performs `n` rounds of "multiply the accumulator by `x`, add the next coefficient". Results are kept as a 16-bit pair (`accL`, `accH`) with carries propagated after each addition. The report describes this as Horner/nested evaluation, since `a₀ + x(a₁ + x(a₂ + … ))` is built up one coefficient at a time from the highest-order term.

### (C) Substring search

Two indices are maintained: `i` into the substring at `90xxH` and `j` into the text at `92xxH`, with `foundIndex` initialised to `FFH`. Characters are compared while they match; on a mismatch the scan restarts at `foundIndex + 1` (or advances `j` when `i = 0`). Termination is on the substring's `00H` (found) or the text's `00H` (not found).

## Memory Map

| Address | Use |
|---------|-----|
| `9000H`–`9009H` | Array of 10 bytes (part A) |
| `9000H` | Substring, NULL-terminated (part C) |
| `9200H` | Text string, NULL-terminated (part C) |
| `9500H` | Key for binary search, per problem statement (part A) |
| `9500H` | `n`, polynomial order (part B) |
| `9500H` | Result index (part C) |
| `9501H` | `x`, evaluation point (part B) |
| `9502H` onwards | Polynomial coefficients (part B) |
| `9550H` | Index result (part A) / low byte of result (part B) |
| `9551H` | High byte of result (part B) |
| internal RAM `27H` | Key actually read by the binary-search code |

## Figures and Results in the Report

| Content | Reference |
|---------|-----------|
| Bubble-sort flowchart | Figure 1 |
| Binary-search flowchart | Figure 2 |
| Polynomial accumulation flowchart | Figure 3 |
| Substring-search flowchart | Figure 4 |
| Sort output screenshots | Figures 5–7 |
| Search output screenshots | Figures 8–10 |
| Polynomial output screenshots | Figures 11–12 |
| Substring output screenshots | Figures 13–17 |
| Sort and search assembly listing | Listing 1 and Listing 2 |

The discussion reports a correctly sorted array, successful binary search with the index or `FFH` written as specified, a 16-bit polynomial result with the high byte staying consistent, and correct substring indices (Figures 5–17).

## Hardware and Software

- Intel 80C51BH trainer kit, external RAM for data
- Keil µVision, Win51

No breadboard peripherals are used in this experiment.

## Source Code

**No `.a51` source files exist for this experiment.** All three assembly programs are available only as typeset listings (Listings 1–2 and the listings preceding them) inside the report PDF. No source file has been reconstructed from the PDF.
