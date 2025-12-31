# Parallel To Serial Converter (PISO)

## 📌 Problem Description

This module implements a **parameterized Parallel-In Serial-Out (PISO)** converter. It accepts **N-bit parallel data** on a valid-ready interface and transmits the data **serially, one bit per cycle**, using another valid ready interface.

The design must correctly handle:
- Backpressure on both parallel and serial sides
- Back-to-back transfers
- Data stability guarantees required by the valid ready protocol

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Overview

### Parallel Interface (Input)
- `p_valid_i` : Indicates valid parallel data
- `p_data_i[DATA_W-1:0]` : Parallel data input
- `p_ready_o` : Converter ready to accept parallel data

### Serial Interface (Output)
- `s_valid_o` : Indicates valid serial data
- `s_data_o`  : Serial output bit
- `s_ready_i` : Downstream ready to accept serial bit

Both interfaces follow the **standard valid ready handshake**:
- Transfer occurs when `valid && ready` is high
- Valid remains asserted until transfer completes
- Data must remain stable until transfer completes

---

## 🧠 Intuition Behind the Design

The converter works in **two conceptual phases**:

1. **Receive Phase (RX)**  
   - Accept the entire parallel word in one cycle
   - Store it internally

2. **Transmit Phase (TX)**  
   - Shift out one bit per cycle
   - Respect downstream backpressure

A **finite state machine (FSM)** cleanly separates these two responsibilities.

---

## 🏗️ Design Approach

### 1️⃣ State Machine

The design uses a 2-state FSM:

| State | Meaning |
|-----|--------|
| `ST_RX` | Waiting to accept parallel data |
| `ST_TX` | Serially transmitting stored data |

- Reset starts the module in `ST_RX`
- Transition to `ST_TX` when parallel transfer completes
- Return to `ST_RX` after all bits are transmitted

---

### 2️⃣ Parallel Data Capture

- Parallel data is accepted when:
  ```
  p_valid_i && p_ready_o
  ```
- Data is loaded into an internal **shift register**
- Bit counter is initialized to zero

`p_ready_o` is asserted **only in RX state**, preventing overwrite during transmission.

---

### 3️⃣ Serial Data Transmission

- `s_valid_o` is asserted in `ST_TX`
- `s_data_o` outputs the **LSB** of the shift register
- On every successful serial transfer (`s_valid_o && s_ready_i`):
  - Shift register shifts right
  - Bit counter increments

This continues until all `DATA_W` bits are sent.

---

### 4️⃣ Handling Backpressure

If `s_ready_i` is low:
- `s_valid_o` remains asserted
- `s_data_o` remains stable
- No shifting or counting occurs

This strictly follows valid ready semantics.

---

### 5️⃣ End of Transmission

- After the last bit is transferred:
  - FSM returns to `ST_RX`
  - `p_ready_o` is reasserted
- `s_data_o` retains its last value as required

---

### 6️⃣ Special Case: DATA_W = 1

For single-bit data:
- FSM and counters are unnecessary
- Logic directly forwards the bit using handshake rules

This keeps the design **correct and minimal** for all widths.

---

## ✅ Key Design Properties

- ✔ Fully parameterized (`DATA_W ≥ 1`)
- ✔ Correct valid ready semantics on both interfaces
- ✔ Supports back-to-back parallel transfers
- ✔ Proper backpressure handling
- ✔ No data loss or duplication
- ✔ Data stability guaranteed

---

## 📘 Learnings and Takeaways

### 🔹 FSMs Simplify Protocol Design

Separating receive and transmit phases avoids corner-case bugs and makes reasoning easier.

---

### 🔹 Valid-Ready Requires Discipline

Correct handling of `valid` and `ready` ensures:
- No dropped data
- No repeated transfers
- Clean interaction with arbitrary downstream logic

---

### 🔹 Parameterization Matters

Supporting edge cases like `DATA_W = 1` is essential for reusable RTL blocks.

---

### 🔹 PISO Is a Foundational Building Block

Parallel-to-serial converters appear in:
- Serial links
- Debug interfaces
- Data streaming pipelines

Understanding this design is crucial for system-level RTL work.

---

## 🚀 Summary

This Parallel-to-Serial converter provides a **robust, parameterized, and protocol-compliant** solution for converting parallel data into serial form. The design balances simplicity, correctness, and scalability, making it suitable for both production designs and RTL interviews.

