# Running Average – Last N Samples

## 📌 Problem Description

This module implements a **parameterized running average calculator** that continuously computes the average of the **last N input samples**.

On every clock cycle:
- A new 32-bit data sample arrives
- The module updates its internal state
- The output `average_o` produces the **average of the most recent N samples**

The design is fully synchronous with **positive-edge triggered flip-flops** and supports **asynchronous reset**.

---

## 🔌 Interface Definition

- **Parameter**
  - `N` : Number of samples used for averaging (power of 2, up to 64)

- **Inputs**
  - `clk`   : Clock
  - `reset` : Active-high reset
  - `data_i[31:0]` : Input data sample (valid every cycle)

- **Outputs**
  - `average_o[31:0]` : Running average of the last `N` samples

---

## ✅ Interface Requirements Recap

- `N` is always a **power of 2** (≤ 64)
- Sum of the last `N` samples never overflows 32 bits
- Average is **rounded down** (floor division)
- Input data is valid **every cycle**
- Output must be produced **every cycle**

---

## 🧠 Intuition Behind the Design

A naïve approach would recompute the sum of the last `N` samples every cycle, but that would be **too slow and expensive**.

Instead, the key insight is:

> The running sum can be updated incrementally by **adding the new sample** and **subtracting the oldest sample**.

Because `N` is a power of 2:
- Division by `N` can be replaced with a **right shift**

This leads to an efficient, high-throughput design.

---

## 🏗️ Design Approach

### 1️⃣ Circular Buffer for Sample Storage

- A register array `data_stack_q[N-1:0]` stores the last `N` samples
- A pointer `stack_ptr_q` marks the **oldest sample**
- Each new sample overwrites the oldest one

This forms a **circular buffer**.

---

### 2️⃣ Sample Count Tracking

During startup, fewer than `N` valid samples exist.

- `count_q` tracks how many samples have been seen
- Once `count_q == N`, the buffer is considered full
- Before the buffer is full, subtraction of old data is disabled

This avoids subtracting invalid data after reset.

---

### 3️⃣ Running Accumulator

A 32-bit accumulator maintains the rolling sum:

```
accumulator_next = accumulator_q + data_i - oldest_sample
```

- `data_i` is always added
- `oldest_sample` is subtracted only after `N` samples have been collected

This guarantees correctness and constant-time updates.

---

### 4️⃣ Pointer Advancement

- `stack_ptr_q` increments every cycle
- Wraparound is automatic due to power-of-2 sizing

This ensures FIFO-like behavior with minimal logic.

---

### 5️⃣ Average Computation

Since `N` is a power of 2:

```
average_o = accumulator >> log2(N)
```

- Produces floor-divided average
- No divider hardware required

---

## ✅ Key Design Properties

- ✔ O(1) update per cycle
- ✔ Fully pipelined (one result per cycle)
- ✔ Efficient hardware (no multipliers/dividers)
- ✔ Parameterized and scalable up to N = 64
- ✔ Correct startup behavior after reset

---

## 📘 Learnings and Takeaways

### 🔹 Sliding Window Problems Love Incremental Updates

Maintaining a running sum is far more efficient than recomputing it each time.

---

### 🔹 Power-of-2 Parameters Simplify Hardware

Shifts are cheaper, faster, and easier to verify than division.

---

### 🔹 Circular Buffers Are Fundamental RTL Structures

They appear in FIFOs, filters, DSP blocks, and monitoring logic.

---

### 🔹 Always Handle the Startup Phase

Correctly managing the "not-yet-full" condition prevents subtle bugs.

---

## 🚀 Summary

This running average module provides a **high-performance, parameterized solution** for computing the average of the last `N` samples every cycle. The design is efficient, scalable, and follows best RTL practices, making it suitable for real-world hardware as well as RTL interviews.
