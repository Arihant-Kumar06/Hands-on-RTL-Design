# Two Pulses – Serial Event Detection Circuit

## 📌 Problem Description

This design implements a sequential circuit that observes **two serial pulse inputs**, `x_i` and `y_i`, and generates an output pulse `p_o` based on a precise temporal relationship between them.

### Functional Requirement

The output `p_o` is asserted **when a pulse on `x_i` is seen**, **provided that**:

- There have been **exactly two pulses on `y_i`**
- These two `y_i` pulses occurred **on or after the last `x_i` pulse**
- The two `y_i` pulses occurred **before the current `x_i` pulse**

Once asserted:
- `p_o` **remains high** until the **next `y_i` pulse**
- Any `y_i` pulse occurring **in the same cycle** as `p_o` assertion is **ignored**

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🧠 Intuition Behind the Design

This is a **temporal pattern detection** problem.

You can think of it as:

> “Fire an output pulse when `x_i` arrives *only if* exactly two `y_i` pulses have happened since the previous `x_i`.”

Key challenges:
- Tracking **how many `y_i` pulses** occurred between `x_i` pulses
- Resetting the count correctly on every `x_i`
- Holding the output high **until a future `y_i` pulse clears it**

The solution uses:
- A **2-bit saturating counter** for `y_i`
- **Edge detection** on `x_i`
- A **latched output** that clears only on `y_i`

---

## 🏗️ Design Approach

### 1️⃣ Counting `y_i` Pulses

A 2-bit register `y_count_q` tracks the number of `y_i` pulses since the last `x_i`.

Rules:
- When `x_i` occurs → reset count (but include `y_i` if both occur together)
- When `y_i` occurs alone → increment count (saturates at `2'b11`)

This ensures accurate tracking of **"exactly two pulses"**.

---

### 2️⃣ Detecting a New `x_i` Pulse

The signal `x_q` is used to detect a **rising edge** of `x_i`:

- `x_en = ~x_q & x_i`

This prevents repeated triggering if `x_i` were ever extended or misaligned.

---

### 3️⃣ Asserting the Output `p_o`

The output is asserted when:

- A **new `x_i` pulse** arrives
- The `y_i` pulse count is **exactly 2** (`y_count_q == 2'b10`)

Formally:
- `p_o = 1` when `(x_q & x_i & y_count_q == 2)`

---

### 4️⃣ Holding and Clearing `p_o`

Once asserted:
- `p_o` **remains high** across cycles
- It is **cleared only by the next `y_i` pulse**
- Pulses on `x_i` while `p_o` is high are ignored

This behavior is implemented using a registered output (`p_q`) with gated updates.

---

### 5️⃣ Update Enable Strategy

Registers update only when necessary:
- `y_count_q` updates on `x_i` or `y_i`
- `p_q` updates on `x_i` or `y_i`

This avoids unnecessary toggling and simplifies reasoning.

---

## ✅ Key Design Properties

- ✔ Exact detection of **two `y_i` pulses**
- ✔ Output assertion aligned with **current `x_i` pulse**
- ✔ Output hold behavior until **future `y_i`**
- ✔ Proper handling of **simultaneous pulses**
- ✔ Fully synchronous with async reset

---

## 📘 Learnings and Takeaways

### 🔹 Temporal Logic Requires State

Problems involving “since last event” **cannot be solved combinationally**, state tracking is essential.

---

### 🔹 Saturating Counters Simplify Control

Using a saturating counter avoids overflow bugs and keeps comparisons clean.

---

### 🔹 Output Hold Logic Is a Common Interview Trap

Many designs incorrectly deassert outputs too early. Latching the output and clearing it explicitly avoids this.

---

### 🔹 Edge Detection Is Safer Than Level Detection

Even when pulses are specified as single-cycle, edge detection adds robustness and clarity.

---

## 🚀 Summary

This design cleanly solves a **non-trivial temporal pulse detection problem** using:
- Minimal state
- Clear separation of counting, detection, and output control
- Robust handling of corner cases

It is an excellent example of **event-driven sequential design** and is well suited for RTL interviews and production quality logic.

