# Embedded Systems Laboratory

Index for the three EC39202 experiments. Start with the [repository README](../README.md) for the overall picture.

| # | Experiment | Date on report | Report |
|---|------------|----------------|--------|
| 01 | Sorting, Searching, Polynomial Evaluation and Substring Matching on 8051 | 8 February 2026 | [PDF](experiment-01-8051-algorithms/report.pdf) |
| 02 | Interfacing and Control of LEDs and Combinational Logic using 8051 | 3 March 2026 | [PDF](experiment-02-led-combinational-logic/report.pdf) |
| 03 | Real-Time Clock with Stopwatch | 3 April 2026 | [PDF](experiment-03-real-time-clock-stopwatch/report.pdf) |

## How the Experiments Fit Together

1. **Experiment 1** stays inside the 8051 and its external RAM. There is no peripheral hardware beyond the trainer kit: the exercise is about addressing modes, pointer arithmetic and algorithm implementation in assembly.
2. **Experiment 2** introduces physical outputs (LEDs through a 74245 driver) and a physical input (an LDR). The combinational logic itself is still evaluated from a table in external memory.
3. **Experiment 3** adds a parallel peripheral (8255 PPI), multiplexed displays and a timer interrupt, producing a small real-time system with two concurrent time bases.

## Common Platform

All three experiments target the Intel 80C51BH on a trainer kit and were written and debugged with Keil µVision and Win51. Program code is assembled at `8100H` unless stated otherwise in the individual report.
