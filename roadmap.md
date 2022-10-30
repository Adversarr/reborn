# Roadmap

## Before In-Progress-Inspection

### Software

Finish `minias`:
- Input: simple asm
- Output: binary code / `verilog simulation code`
- Purpose: check for the correctness of Verilog-Simulated-CPU

> You can use the basic code in `utils/minias`. 

Finish up `SeuLexYacc`, a "simple" compiler frontend:
- Input: c99
- Output: Abstract Syntax Tree.

> [Link](https://github.com/Adversarr/SeuLexYacc)

The frontend is fully-tested, the only drawback is the performance.

### Hardware

Finish the basic requirement.

> finish by yzr

### Interface!!!

I need someone to finish up the design of the interface. See `minisys1.v`: I/O interface is pretty complex. I need someone to tell me how can hardware and software can cooperate with each other.

> Refer to: 补充讲义-4.2端口地址定义

