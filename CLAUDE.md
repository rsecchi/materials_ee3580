# materials_ee3580

Public GitHub repo (`github.com/rsecchi/materials_ee3580`, branch `master`) with hardware/software
materials for EE3580 Digital Systems (University of Aberdeen). The repo is **public**: never add
student names, usernames, marks, passwords or other personal data.

## Layout

| Path | What it is |
|---|---|
| `CPU_edu/` | `CPU_edu`: an 8-bit educational CPU in Verilog, its assembler and test benches |
| `25LC256_eeprom/` | Arduino driver for the Microchip 25LC256 SPI EEPROM (`25LC256.h/.cpp`, example `.ino`) |
| `misc_verilog/` | Small Verilog examples (e.g. `dpll.v`, a DPLL simulation) |
| `Kicad/lab_components/` | KiCad symbol + footprint library for the lab kit (PCB lab). Install with the nickname `lab_components`; see `Kicad/README.md`. The working copy in the course folder is `Laboratories\LIBRARIES`, with zipped versions also in `Gerbers\LIBRARIES.zip` |
| `utils/` | Admin scripts for the Raspberry Pi used in earlier years (see below) |

## CPU_edu

- **Registers:** 16 × 8-bit (`R0`–`R15`), 15-bit instruction pointer `IP`, status register `SREG`.
  `R14:R15` form the address pointer used by `LD`/`ST`.
- **Instruction formats** (16 bits, opcode in bits 15:12):
  - `oooo rrrr 00000000`: one register operand
  - `oooo dddd 0000ssss`: register, register
  - `oooo rrrr yyyyyyyy`: register, 8-bit immediate
- **Opcodes:** the source of truth is `CPU_edu.v` (ALU and decode unit) and the mnemonic table in
  `compiler_16b.c`:

  | Opcode | Instr | Opcode | Instr | Opcode | Instr | Opcode | Instr |
  |---|---|---|---|---|---|---|---|
  | 0000 | NOP | 0100 | LD reg | 1000 | LSL reg | 1100 | ADD reg, reg |
  | 0001 | ST reg | 0101 | ADI reg, imm | 1001 | COM reg | 1101 | ADC reg, reg |
  | 0010 | BREQ imm | 0110 | LDI reg, imm | 1010 | NEG reg | 1110 | AND reg, reg |
  | 0011 | RJMP imm | 0111 | LSR reg | 1011 | MOV reg, reg | 1111 | OR reg, reg |

  Known issue: the table in `README.md` is wrong. It lists ADD/ADC/AND/OR as 1010–1101
  (clashing with NEG and MOV) and spells RJMP as "RJPM".
- **Toolchain:** `gcc` (assembler) + Icarus Verilog (`iverilog`, `vvp`); view `.vcd` waveforms with GTKWave.
- **Build/simulate** (from `CPU_edu/`):
  - `make comp16` builds the assembler `comp16` from `compiler_16b.c`
    (`./comp16 <file.asm> [rom.mem]`).
  - `make <name>.vcd` assembles `<name>.asm` into `rom.mem`, simulates `CPU_edu.v` with
    `test_cpu.v`, and renames the dump to `<name>.vcd`.
  - Example programs: `ex_sum.asm` (16-bit add with carry), `ex_count.asm`, `ex_reverse.asm`,
    `ex_ass1.asm`, `hamming.asm`, `mul.asm`.
  - The `testagu`/`testrom`/`testdu`/`testalu` Makefile targets reference `CPU.v`, which no
    longer exists (only `CPU.v.bak`), so they are stale.
- The local clone holds many files that were never committed: the test benches (`cpu_test.v`,
  `test_*.v`), example programs (`hamming.asm`, `mul.asm`, `ex_ass1.asm`, `mytest.asm`) and
  build outputs (`*.vcd`, `*.vvp`, `a.out`, `comp`, `comp16`, `cpu`, `test`, `file`, `*.img`).
  Build outputs should not be committed; adding a `.gitignore` for them is still to do.

## utils/

Bash scripts for the shared Raspberry Pi used for the Linux part of the course in 2018–2020.
They are no longer part of the current course, which now uses FreeRTOS on the Arduino Uno.
- `create_cohort <file>` / `delete_cohort <file>`: create or delete one Linux account per line
  of a cohort file (username `id<line>`), with home directories in `/home/ee3580`. **Cohort files
  contain student IDs and must never be committed.**
- `connect_pi`: opens a reverse SSH tunnel from the Pi to a VPS (port 2222).

## Conventions

- British English in student-facing text.
- Before pushing, check `git diff --cached` for personal data, credentials or password hashes.
