# Cross Correlation – Serial Event Expectation Detector

## 📌 Problem Description

This module implements a **cross-correlation–style detector** for two serial input signals `sig_x_i` and `sig_y_i`.

- `sig_x_i` generates sporadic `1`s
- `sig_y_i` contains the **same number of `1`s**, but each `1` may be **delayed by up to 32 clock cycles** relative to `sig_x_i`

The goal of the circuit is to generate an output `z_o` that indicates **when we are expecting a `1` on `sig_y_i`**, based on previously observed `1`s on `sig_x_i` that have not yet been matched.

This is a classic **hardware-friendly cross-correlation / outstanding-event tracking** problem.

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Definition

### Inputs
- `clk` : Clock signal
- `reset` : Active-high reset
- `sig_x_i` : Serial input signal X
- `sig_y_i` : Serial input signal Y (delayed version of X)

### Output
- `z_o` : Asserted when a `1` is *expected* on `sig_y_i`

---

## ✅ Interface Guarantees

- Every `1` seen on `sig_x_i` **will eventually appear on `sig_y_i`**
- The delay between `sig_x_i` and corresponding `sig_y_i` is **≤ 32 cycles**
- Inputs are fully independent (no handshake)
- Output must be produced **every cycle**

---

## 🧠 Intuition Behind the Design

Instead of explicitly measuring delay or storing timestamps, we track the **difference between how many `1`s have occurred on `sig_x_i` and how many have already been observed on `sig_y_i`.**

Key insight:

> If more `1`s have been seen on `sig_x_i` than on `sig_y_i`, then we are *expecting* future `1`s on `sig_y_i`.

So:
- Maintain a **running counter** of outstanding events
- Increment on `sig_x_i == 1`
- Decrement on `sig_y_i == 1`
- Assert `z_o` whenever the counter is non-zero

This avoids any need for shift registers, FIFOs, or delay tracking.

---

## 🏗️ Design Approach

### 1️⃣ Outstanding Event Counter

A 5-bit counter is used:

```
count_next = count_q + sig_x_i - sig_y_i
```

- `sig_x_i` contributes `+1`
- `sig_y_i` contributes `-1`

The 5-bit width is sufficient because:
- Maximum outstanding events ≤ 32

---

### 2️⃣ Counter Register

The counter is registered every cycle:

```
always_ff @(posedge clk or posedge reset)
  if (reset)
    count_q <= 0;
  else
    count_q <= count_next;
```

On reset, no outstanding events exist.

---

### 3️⃣ Output Logic

The output is asserted whenever there is **at least one unmatched `sig_x_i` pulse**:

```
z_o = |count_q;
```

This directly answers the question:

> “Should we expect a `1` on `sig_y_i`?”

---

## 🔁 Example Behavior

| Cycle | sig_x_i | sig_y_i | count_q | z_o |
|------|--------|--------|---------|-----|
| Reset | 0 | 0 | 0 | 0 |
| 1 | 1 | 0 | 1 | 1 |
| 2 | 0 | 0 | 1 | 1 |
| 3 | 0 | 1 | 0 | 0 |
| 4 | 1 | 0 | 1 | 1 |
| 5 | 1 | 0 | 2 | 1 |
| 6 | 0 | 1 | 1 | 1 |
| 7 | 0 | 1 | 0 | 0 |

---

## ✅ Key Design Properties

- ✔ No storage of historical samples
- ✔ No multipliers or comparators
- ✔ Constant-time per cycle (O(1))
- ✔ Bounded hardware (5-bit counter)
- ✔ Works for arbitrary delay up to 32 cycles

---

## 📘 Learnings and Takeaways

### 🔹 Cross-Correlation Can Be Simplified

You don’t always need shift registers or windowed correlation, **event counting is enough** when guarantees exist.

---

### 🔹 Hardware Loves Invariants

The guarantee that X and Y have equal pulse counts enables a very compact design.

---

### 🔹 Counters Are Powerful Abstractions

A single counter captures system-level temporal behavior cleanly.

---

### 🔹 This Pattern Is Widely Used

Similar ideas appear in:
- Credit-based flow control
- Outstanding transaction tracking
- Scoreboards
- DMA completion logic

---

## 🚀 Summary

This Cross Correlation module uses a **minimal-area counter-based technique** to determine when future events are expected on a delayed signal. By tracking unmatched pulses instead of explicit timing, the design achieves correctness, simplicity, and efficiency—making it ideal for SoC signal monitoring and event alignment logic.

