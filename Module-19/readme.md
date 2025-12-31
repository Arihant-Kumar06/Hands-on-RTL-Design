# Performance Counters – Base Counter Module

## 📌 Problem Description

This module implements a **parameterized CPU performance counter**, intended to be used as a building block for a **processor performance monitoring unit (PMU)**.

Each counter:
- Increments on a **single-bit trigger event** from the CPU pipeline
- Is **readable only by software** via an explicit read request
- **Resets to zero after a successful software read**

The design supports instantiating multiple such counters in a CPU, each monitoring a different event.

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Definition

- **Inputs**
  - `clk` : Clock
  - `reset` : Active-high reset
  - `sw_req_i` : Software read request
  - `cpu_trig_i` : CPU event trigger (1-cycle pulse)

- **Output**
  - `p_count_o[CNT_W-1:0]` : Counter value visible to software

---

## ✅ Interface Requirements Recap

- Counter increments on every `cpu_trig_i`
- Counter value is **visible only during a software read**
- After a software read completes, the counter **resets to zero**
- Software reads and CPU trigger events are **independent**
- Output must be **zero when no software read is active**
- Counter width is parameterizable using `CNT_W`

---

## 🧠 Intuition Behind the Design

Performance counters are meant to:
- Continuously count internal CPU events
- Expose their value **only when software explicitly asks for it**

A key requirement is:

> Software should see a *snapshot* of the counter, and the counter should restart immediately after the read.

Thus, the design must:
1. Accumulate events over time
2. Present the accumulated value on demand
3. Clear the counter after the read

All while allowing trigger events and reads to happen independently.

---

## 🏗️ Design Approach

### 1️⃣ Internal Counter Register

- `count_q` holds the running count of CPU trigger events
- It increments by `1` whenever `cpu_trig_i` is asserted

---

### 2️⃣ Handling Software Read Requests

When `sw_req_i` is asserted:
- The **current counter value** is driven onto `p_count_o`
- The counter is prepared to **reset after the read**

This is achieved by modifying the next-state logic:

- If `sw_req_i = 1`, the next count becomes `cpu_trig_i` (i.e., reset + possible new event)
- Otherwise, the counter continues accumulating

---

### 3️⃣ Counter Reset After Read

The counter reset is implicit:

```
count_next = cpu_trig_i   (when sw_req_i is high)
```

This ensures:
- The old count is exposed for one cycle
- The next cycle starts fresh

---

### 4️⃣ Output Gating

The output is gated by the software request:

```
p_count_o = sw_req_i ? count_q : 0
```

This ensures:
- Software sees valid data only during a read
- The output is zero at all other times

---

## 🔁 Sample Behavior Walkthrough

| Scenario | Behavior |
|--------|----------|
| Reset | Counter = 0, output = 0 |
| CPU triggers only | Counter increments internally, output remains 0 |
| Software read | Output shows accumulated count |
| Cycle after read | Counter resets to 0 |
| Concurrent trigger + read | Read old value, new event starts fresh count |

---

## ✅ Key Design Properties

- ✔ Parameterized counter width
- ✔ Independent software read and CPU trigger
- ✔ Snapshot-style read semantics
- ✔ Automatic reset after read
- ✔ No spurious output when not reading

---

## 📘 Learnings and Takeaways

### 🔹 Performance Counters Are Snapshot-Based

They provide point-in-time visibility, not continuous streaming.

---

### 🔹 Gating Outputs Simplifies Software Contracts

Driving zero when idle avoids stale or misleading values.

---

### 🔹 Reset-on-Read Is a Common PMU Pattern

Used extensively in real CPUs (x86, ARM, RISC-V PMUs).

---

### 🔹 Independence of Events and Reads Is Crucial

Counter correctness must not depend on software timing.

---

## 🚀 Summary

This performance counter module provides a **clean, reusable, and CPU-friendly implementation** of a base PMU counter. It cleanly separates event counting from software visibility, supports parameterization, and follows industry-standard reset-on-read semantics.



