# Edge Capture – Sticky Negative Edge Detector

## 📌 Problem Description

This module implements a **sticky edge capture circuit** that detects **negative edges (1 → 0 transitions)** on a **32-bit input bus**. The detection is performed **independently for each bit**, and once an edge is detected on a bit, the corresponding output bit remains asserted until a reset occurs.

### Functional Requirements

- Input: `data_i[31:0]`
- Output: `edge_o[31:0]`

The output must:
- Assert when a **neg-edge** is detected on the corresponding input bit
- Remain asserted (**sticky**) until reset
- Be produced **every cycle**

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🧠 Intuition Behind the Design

This problem is about **event capture**, not just event detection.

A simple edge detector would raise a pulse for one cycle, but here:

> Once a bit falls from `1 → 0`, we want to **remember forever** (until reset) that it happened.

So the circuit needs to:
1. Remember the **previous value** of each input bit
2. Compare it with the **current value**
3. Detect a `1 → 0` transition
4. **Latch that information permanently**

This pattern is extremely common in:
- Interrupt controllers
- Status registers
- Error capture logic
- Debug and monitoring blocks

---

## 🏗️ Design Approach

### 1️⃣ Previous Data Register

A register `data_q[31:0]` stores the **previous cycle’s input**:

- Updated every cycle
- Used as the reference for edge detection

---

### 2️⃣ Negative Edge Detection

A neg-edge on a bit occurs when:

```
previous = 1  AND  current = 0
```

This is expressed as:

```
~data_i & data_q
```

This logic is applied **bitwise** across all 32 bits.

---

### 3️⃣ Sticky Capture Logic

To make the detection sticky:

- The detected edge is OR’ed with the **previously latched edge state**

```
edge_next = neg_edge_detected | edge_q
```

Once a bit becomes `1`, it **can never clear** until reset.

---

### 4️⃣ Sequential Update

Both registers update on the same clock edge:

- `data_q` captures the new input
- `edge_q` captures the accumulated edge information

This guarantees:
- No race conditions
- Fully synchronous behavior

---

### 5️⃣ Output Logic

The output is driven directly from the computed next state:

```
edge_o = edge_next
```

This ensures the output is **valid every cycle**, including the cycle in which the edge is detected.

---

## ✅ Key Design Properties

- ✔ Per-bit negative edge detection
- ✔ Sticky behavior until reset
- ✔ Fully synchronous operation
- ✔ Simple, scalable logic (easy to extend beyond 32 bits)
- ✔ No combinational feedback loops

---

## 📘 Learnings and Takeaways

### 🔹 Edge Capture ≠ Edge Pulse

Capturing an event is often more useful than generating a short pulse — especially for software-visible status bits.

---

### 🔹 Stickiness Simplifies System Design

Sticky flags prevent missed events when the consumer checks status infrequently.

---

### 🔹 Bitwise Logic Scales Well

This design naturally generalizes to any bus width with no change in structure.

---

### 🔹 Always Store Previous State Explicitly

Reliable edge detection always requires remembering the past — guessing leads to bugs.

---

## 🚀 Summary

This edge capture module provides a **robust and efficient solution** for detecting and remembering negative edges on a multi-bit bus. It is a classic RTL building block used across SoCs for status, interrupt, and error handling.


