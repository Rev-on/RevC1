
---
title: "RevC1 RISC-V MCU"
author: "Rev.on"
layout: default
---

# RevC1 - A Compact RISC-V MCU

RevC1 is a compact RISC-V-based microcontroller designed for the Tiny Tapeout SKY130 shuttle. It occupies a 3x4 tile area and runs at 40MHz.

## How it works

The design implements a subset of the RV32I base integer instruction set with the following features:

### Core Features
- **RISC-V CPU**: 32-bit processor supporting ADD, SUB, AND, OR, XOR, shift operations, and conditional branches
- **AHB-Lite Bus**: System bus with arbitration between CPU master and peripheral slaves
- **Instruction Memory**: 4KB on-chip ROM for program storage

### Peripherals
| Peripheral | Description | Address Map |
|------------|-------------|-------------|
| UART | 115200 baud serial communication | 0x1000_1000 |
| I2C Master | Two-wire interface for external sensors | 0x1000_2000 |
| GPIO | 8-bit bidirectional general-purpose I/O | 0x1000_0000 |
| Timer/PWM | 32-bit counter with PWM output | 0x1000_3000 |

### Physical Specifications
- **Process**: SkyWater 130nm (SKY130)
- **Tile Size**: 3x4 (12 tiles total)
- **Clock Frequency**: 40MHz (configurable via constraints)
- **Core Area**: ~400 x 400 μm
- **Logic Cells**: ~1500 standard cells

### Block Diagram
``` text
┌─────────┐      ┌─────────────┐      ┌──────────────┐
│   CPU   │────▶│ CPU-to-AHB  │────▶│ AHB-Lite Bus │
│  Core   │◀────│  Adapter    │◀────│  (Arbiter)   │
└─────────┘      └─────────────┘      └──────┬───────┘
                                             │
                      ┌──────────┬───────────┼───────────┬──────────┐
                      ▼          ▼           ▼           ▼          ▼
                  ┌──────┐  ┌──────┐    ┌──────┐    ┌──────┐  ┌──────┐
                  │ GPIO │  │ UART │    │ I2C  │    │Timer │  │ MEM  │
                  │ 8bit │  │115.2k│    │Master│    │/PWM  │  │ 4KB  │
                  └──────┘  └──────┘    └──────┘    └──────┘  └──────┘
```

## How to test

### Required Equipment
- Tiny Tapeout Demo Board (or any carrier board with 40-pin PMOD)
- 3.3V/5V power supply (provided by demo board)
- USB-to-UART adapter (for serial communication)
- Logic analyzer or oscilloscope (optional, for debugging)

### Test Procedure

#### 1. Power Up and Reset
1. Connect the demo board to USB power
2. Apply 40MHz clock signal to `clk` pin
3. Assert `rst_n` low for at least 10 clock cycles, then de-assert high

#### 2. UART Communication Test
Monitor `uo_out[0]` (UART TX) at 115200 baud, 8-N-1 format:
- On reset, the core should output a startup message: `"RevC1 Ready\n"`
- Send commands via `ui_in[0]` (UART RX):
  - `?` - Help message
  - `S` - Status report
  - `G` - GPIO read/write
  - `T` - Timer read

#### 3. GPIO Test
- The 8 GPIO pins are available on `uio[7:0]` (bidirectional)
- On reset, GPIO pins default to inputs (high-Z)
- Write to GPIO output register via UART command `G W <value>` to drive pins high/low
- Read GPIO input register via UART command `G R`

#### 4. PWM Output Test
- `uo_out[1]` provides PWM output
- Default PWM frequency is ~1kHz at 50% duty cycle
- PWM duty cycle can be adjusted by writing to timer compare register

#### 5. I2C Master Test
- I2C clock on `uio[1]`, data on `uio[2]` (both open-drain)
- Connect an I2C device (e.g., 24LC64 EEPROM) to these pins
- Use UART command `I <dev_addr> <reg_addr> <data>` to perform I2C transactions

### Debug Signals
| Signal | Pin | Description |
|--------|-----|-------------|
| debug_sel[2:0] | uo_out[4:2] | Current pipeline stage (0=FETCH,1=DECODE,2=EXECUTE,3=MEM,4=WB) |
| debug_data | uo_out[5] | PC bit toggle per instruction |

## External Links

- [GitHub Repository](https://github.com/Rev-on/RevC1)

## Contact

- **Author**: Rev.on
- **Email**: [laoyuyuchengzhuo2011@outlook.com]

## License

This project is open source under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
