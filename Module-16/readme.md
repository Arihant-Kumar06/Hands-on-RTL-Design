# Big Endian Converter – Little to Big Endian Transformation

## 📌 Problem Description

This module implements a **parameterized Little Endian to Big Endian converter**. It is designed to bridge systems that use **different byte ordering conventions**, such as a **little-endian CPU subsystem** interfacing with a **big-endian networking chip**.

The converter rearranges the byte order of the input data so that the **least significant byte becomes the most significant byte**, and vice versa.

The conversion is purely **combinational**, meaning:
- The output is available in the **same cycle**
- The module produces valid output **every cycle**

Although the interface includes clock and reset signals for consistency, **no sequential logic is required**.

---

## 🔌 Interface Definition

- **Parameter**
  - `DATA_W` : Width of the data bus (byte-aligned, multiple of 8)

- **Inputs**
  - `clk` : Clock (not used in logic)
  - `reset` : Active-high reset (not used in logic)
  - `le_data_i[DATA_W-1:0]` : Input data in little-endian format

- **Outputs**
  - `be_data_o[DATA_W-1:0]` : Output data in big-endian format

---

## ✅ Interface Requirements Recap

- Output must be generated **in the same cycle** as input
- Output must be valid **every cycle**
- Data width is **byte-aligned**
- No internal state required

---

## 🧠 Intuition Behind the Design

Endian conversion is fundamentally a **byte reordering problem**.

- In **little-endian**, the least significant byte (LSB) appears at the lowest address
- In **big-endian**, the most significant byte (MSB) appears at the lowest address

To convert from little to big endian:

> Reverse the order of bytes while keeping the bits within each byte unchanged.

For example (32-bit data):

```
Little Endian: [B0][B1][B2][B3]
Big Endian   : [B3][B2][B1][B0]
```

---

## 🏗️ Design Approach

### 1️⃣ Byte-Level Partitioning

The input bus is divided into **8-bit byte slices**:

- Byte `i` occupies `le_data_i[i*8 +: 8]`

---

### 2️⃣ Reversed Byte Mapping

Each input byte is mapped to the mirrored position in the output bus:

```
be_data_o[(DATA_W-1) - 8*i -: 8] = le_data_i[i*8 +: 8]
```

This effectively reverses the byte order across the entire word.

---

### 3️⃣ Parameterization

The logic is wrapped inside a `for`-generate loop:

- Works for **any DATA_W** that is a multiple of 8
- Automatically adapts to 16-bit, 32-bit, 64-bit, etc.

---

### 4️⃣ Combinational Operation

- No registers are used
- No latency is introduced
- Conversion happens purely through wiring

This satisfies the requirement of **same-cycle output availability**.

---

## ✅ Key Design Properties

- ✔ Zero-latency conversion
- ✔ Fully parameterized (any byte-aligned width)
- ✔ No clock dependency
- ✔ No state or reset behavior
- ✔ Simple, synthesizable logic

---

## 📘 Learnings and Takeaways

### 🔹 Endianness Is About Byte Order, Not Bit Order

Bits inside a byte remain unchanged, only byte positions move.

---

### 🔹 Generate Loops Enable Clean Parameterized RTL

Using `genvar` avoids repetitive code and scales cleanly with bus width.

---

### 🔹 Prefer Combinational Logic When Possible

For pure format conversion, registers only add unnecessary latency.

---

### 🔹 This Is a Common SoC Integration Problem

Endian converters are frequently required when interfacing:
- CPUs and peripherals
- Networking blocks
- DMA engines

Understanding this pattern is essential for system-level RTL design.

---

## 🚀 Summary

This Big Endian Converter provides a **simple, efficient, and reusable solution** for converting little-endian data into big-endian format. With zero latency and full parameterization, it is ideal for SoC integration scenarios and serves as a classic RTL building block.
