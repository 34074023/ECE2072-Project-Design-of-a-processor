# ECE2072 Project: Design of a processor
A hardware description project focused on the modular design, simulation, and implementation of a processor architecture. The project scales from fundamental hardware components to an extended processor capable of execution, memory interaction, and 7-segment display decoding.
## Architecture
The processor was built incrementally across four key milestones, focusing on synchronous hardware design and extensive testbench verification:

### 1. Core Hardware Modules
Designed and verified critical low-level arithmetic and control units:
* **ALU (Arithmetic Logic Unit):** Handles basic operations including addition, subtraction, multiplication, and logical bit-shifting (`SSI`).
* **Control Units & Registers:** Features a tick finite state machine (`tick_FSM`), an $N$-bit parameterizable register (`register_n`), multiplexers, and a sign extender.

### 2. Simple Processor (`proc`)
Integrates core modules into a functioning central processing unit supporting a foundational instruction set:
* Data movement and immediate manipulation (`MOVI`).
* Immediate and register arithmetic (`ADD`, `ADDI`, `SUB`, `MUL`).
* Bitwise operations (Shift Left Immediate `SSI`).

### 3. Extended Processor (`proc_extension`)
Expands the ISA (Instruction Set Architecture) to bridge internal processing with physical peripherals:
* **Peripheral Integration:** Integrated a custom Binary-Coded Decimal (`bcd_decoder`) module.
* **Output Visualization:** Features the `DISP` instruction to output negative numbers, large products, and real-time operations to hardware displays.

### 4. Memory & Program Control (`proc_memory`)
Implements basic memory mapping and program control pipelines using standard Memory Initialization Files (`.mif`) to execute autonomous assembly programs (e.g., Fibonacci sequence calculations).
* **Verification Scope:** While the experimental execution pipeline was mapped conceptually to run standard assembly logic (such as a Fibonacci loop), current validation relies on direct testbench simulation vectors (`proc_tb` and `proc_extension_tb`) rather than standalone static `.mif` configurations.

## Tech Stack & Tools
* **Hardware Description Language:** Verilog / VHDL (Hardware Design & Structural Modeling)
* **Simulation & Verification:** ModelSim / QuestaSim (Waveform analysis, testbench validation)
* **Target Hardware Context:** Intel/Altera Quartus Prime (FPGA Deployment workflow)

## Verification & Demonstration Plans

The architecture is fully validated using comprehensive testbenches (`proc_tb` and `proc_extension_tb`). Below are the standard execution routines used to verify correctness:

### Testbench Routines
1. **Mathematical Validation:** Executes sequential logic like loading values (`MOVI R1, 5`), adding, subtracting, and computing large multiplication boundaries (`6400` via `MUL`).
2. **Edge-Case / Negative Number Handling:** Verifies signing math operations (e.g., `3 - 5 = -6`) and formats them cleanly for peripheral output via `DISP`.
3. **Bit-Shifting Logic:** Evaluates cycle-accurate bit manipulations with immediate values.

## Current Project Status & Known Limitations
* **Core & Extended Processor:** 100% functional with clean, cycle-accurate simulation waveforms across all standard arithmetic operations.
* **Memory & Branching Pipeline:** Fully maps programs from `.mif` instruction storage. *Known Bug:* The Program Counter (`pc`) logic occasionally experiences unexpected branching behaviors during autonomous execution blocks (e.g.,the given Fibonacci assembly loops), resulting in a 75% complete implementation for this experimental subsystem.
*  

## Contributors (Team 49)
* **Chan Kai Xiang** – Lead for `tick_FSM`, multiplexer, `register_n`, Core CPU Pipeline (`proc`), and Verification Testbenches.
* **Jacob Michael Low Ken Heng** – Lead for ALU, Sign Extender, `bcd_decoder` peripheral, Extended CPU Pipeline (`proc_extension`), and Verification Testbenches.
