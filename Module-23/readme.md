# Compression Engine – Mantissa & Exponent Based Vector Compression

## 📌 Problem Description

This module implements a **compression engine** that converts a **24-bit input vector** into a compact representation consisting of:
- a **12-bit mantissa**
- a **4-bit exponent**

The compressed representation can later be expanded back into an approximate 24-bit vector using the following rule:

```
if (exponent == 0)
  vector = mantissa
else
  vector = {1'b1, mantissa, {exponent-1{0}}}
```

This technique is widely used in hardware (floating-point, DSPs, ML accelerators) to **reduce storage and bandwidth** while tolerating limited precision loss.

The output must be produced **in the same cycle** as the input.

---

## 🔌 Interface Definition

### Inputs
- `num_i[23:0]` : 24-bit input vector to be compressed

### Outputs
- `mantissa_o[11:0]` : 12-bit mantissa
- `exponent_o[3:0]`  : 4-bit exponent

---

## ✅ Interface Requirements Recap

- Output must be **combinational (same-cycle)**
- Mantissa width is fixed to 12 bits
- Exponent width is fixed to 4 bits
- Compression must follow the reconstruction rule exactly

---

## 🧠 Intuition Behind the Design

The compression scheme is based on the idea of **normalization**:

- If the number fits entirely within 12 bits → no exponent needed
- Otherwise:
  - Find the **most significant set bit (MSB)**
  - Encode how far the number must be shifted using the exponent
  - Store the **next 12 significant bits** as mantissa

In essence:

> The exponent captures the magnitude, and the mantissa captures the precision.

---

## 🏗️ Design Approach

### 1️⃣ Detect the Leading One (MSB Detection)

- A one-hot vector (`exp_oh`) is generated
- Only the **highest set bit between bit[23:12]** is marked

This is done by masking lower bits once a higher bit is detected.

---

### 2️⃣ One-Hot to Binary Conversion

The one-hot MSB position is converted into a binary exponent index using the shared module:

```
qs_1hot_bin
```

This gives the **log2 position** of the MSB.

---

### 3️⃣ Exponent Computation

- If no MSB is detected in `[23:12]`, exponent = 0
- Otherwise:

```
exponent = MSB_position + 1
```

This matches the reconstruction rule which inserts `exponent-1` zeros.

---

### 4️⃣ Mantissa Extraction

Two cases:

#### Case 1: Exponent = 0

- Entire value fits in mantissa

```
mantissa = num_i[11:0]
```

#### Case 2: Exponent > 0

- Mantissa takes the **12 bits immediately following the MSB**

```
mantissa = num_i[exponent+11-1 -: 12]
```

This ensures correct reconstruction of the most significant bits.

---

## 🔁 Worked Examples

### Example 1

```
Input  : 0x0000FC
Exponent = 0
Mantissa = 0x0FC
```

Reconstruction:
```
vector = mantissa
```

---

### Example 2

```
Input  : 0xFFC01D
MSB    : bit[23]
Exponent = 12 (0xC)
Mantissa = 0xFF8
```

Reconstruction:
```
{1'b1, 12'b111111111000, 11'b0} = 0xFFC000
```

---

## ✅ Key Design Properties

- ✔ Same-cycle output (pure combinational logic)
- ✔ Deterministic compression scheme
- ✔ Simple reconstruction logic
- ✔ Uses leading-one detection
- ✔ Parameter-aligned mantissa/exponent widths

---

## 📘 Learnings and Takeaways

### 🔹 This Is a Fixed-Point Normalization Scheme

Very similar to floating-point encoding but simplified and hardware-friendly.

---

### 🔹 Leading-One Detection Is a Fundamental Primitive

Used extensively in:
- FP normalization
- Priority encoders
- Compression engines

---

### 🔹 One-Hot Encoding Simplifies MSB Logic

One-hot → binary conversion avoids complex priority encoders.

---

### 🔹 Compression Trades Precision for Bandwidth

Lower bits are truncated, but magnitude information is preserved efficiently.

---

## 🚀 Summary

This Compression Engine cleanly converts a 24-bit value into a **mantissa–exponent representation**, enabling compact storage and efficient reconstruction. The design is fully combinational, precise in its MSB handling, and reflects real-world compression techniques used in CPUs, DSPs, and ML hardware.



