# Perfect Squares Generator – Multiplier-Free Design

## 📌 Problem Description

This module generates a sequence of **perfect squares** on every clock cycle:

```
4 → 9 → 16 → 25 → 36 → 49 → 64 → 81 → ...
```

Each output represents the square of consecutive integers starting from:

```
2², 3², 4², 5², ...
```

Since this circuit is intended for **area-constrained SoCs (e.g., smartwatches)**, the design **must not use a multiplier**. Instead, it should rely on **simple arithmetic operations** such as addition.

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Definition

### Inputs
- `clk` : Clock signal
- `reset` : Active-high reset

### Output
- `sqr_o[31:0]` : 32-bit output producing one perfect square per cycle

---

## 🧠 Intuition Behind the Design

The key mathematical insight is:

> **The difference between consecutive perfect squares is an odd number.**

Specifically:

```
(n+1)² = n² + (2n + 1)
```

So the sequence of increments is:

```
+5, +7, +9, +11, +13, ...
```

Instead of computing `n × n`, we can:
1. Keep track of the **current square**
2. Add the **next odd number** every cycle

This completely eliminates the need for a multiplier.

---

## 🏗️ Design Approach

### 1️⃣ Odd-Number Counter

- `count_q` holds the current odd increment
- Initialized to `3` on reset
- Incremented by `2` every cycle

This generates:

```
3, 5, 7, 9, 11, ...
```

---

### 2️⃣ Square Accumulator

- `sqr_q` holds the previous square value
- Initialized to `1` on reset
- Updated as:

```
sqr_next = sqr_q + count_q
```

This produces:

```
1 → 4 → 9 → 16 → 25 → ...
```

The output `sqr_o` is driven directly from the computed next value.

---

### 3️⃣ Reset Behavior

On reset:
- `count_q = 3`
- `sqr_q   = 1`

On the first active cycle:
```
sqr = 1 + 3 = 4
```

Thus the sequence starts correctly at **4**.

---

## 🔁 Cycle-by-Cycle Example

| Cycle | count_q | sqr_q | sqr_o |
|------|--------|-------|-------|
| Reset | 3 | 1 | — |
| 1 | 3 | 1 | 4 |
| 2 | 5 | 4 | 9 |
| 3 | 7 | 9 | 16 |
| 4 | 9 | 16 | 25 |

---

## ✅ Key Design Properties

- ✔ No multiplier used
- ✔ Only adders and registers
- ✔ One output per cycle
- ✔ Very low area cost
- ✔ Deterministic and monotonic output

---

## 📘 Learnings and Takeaways

### 🔹 Math Can Replace Hardware

Simple mathematical identities often eliminate expensive hardware like multipliers.

---

### 🔹 Odd Numbers Drive Square Sequences

Perfect squares are just cumulative sums of odd numbers.

---

### 🔹 Area-Optimized Designs Favor Adders

Adders are far cheaper than multipliers in silicon, especially for low-power SoCs.

---

### 🔹 This Pattern Is Widely Used

Similar techniques are used in:
- Graphics engines
- DSP pipelines
- Low-power numerical hardware

---

## 🚀 Summary

This Perfect Squares Generator demonstrates how **simple arithmetic and mathematical insight** can replace costly hardware blocks. By leveraging the odd-number property of squares, the design produces a continuous sequence of perfect squares using only adders and registers—making it ideal for **area- and power-constrained systems**.

---

📂 *This README is ready to be used directly as `README.md` in a GitHub repository.*