# LRU – Least Recently Used Replacement Policy (N-Way Cache)

## 📌 Problem Description

This module implements a **Least Recently Used (LRU)** replacement policy for an **N-way set associative cache**, where `NUM_WAYS` is a **parameterized power of 2**.

The LRU logic tracks the relative age of cache ways and selects the **least recently used way** for replacement on a write (store) operation.

### Supported Operations

The input operation type `ls_op_i` is encoded as:

| Encoding | Operation |
|--------|-----------|
| `2'b01` | Read (Load) |
| `2'b10` | Write (Store) |
| `2'b11` | Invalidate |

The module must:
- Output the **replacement way on the same cycle** as the operation
- Provide the output as a **one-hot encoded vector**
- Correctly update LRU state on **read, write, and invalidate** operations

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🧠 Intuition Behind the Design

The core idea of LRU is simple:

> *The block that hasn’t been used for the longest time should be replaced first.*

To implement this in hardware:
- We need to **remember ordering information** between all cache ways
- Every access (read or write) updates this ordering
- On replacement, we select the **oldest valid way**, or a **free way if available**

This design uses a **pairwise age-tracking matrix**, which is a classic and interview-favorite approach for LRU.

---

## 🏗️ Design Approach

### 1️⃣ Way Availability Tracking

A register `way_avail_q` tracks which ways are currently **free**:

- `1` → way is available (unused)
- `0` → way contains valid data

On reset:
- All ways are marked **available**

On operations:
- **Write (Store)** consumes a way
- **Invalidate** frees a way

This allows the design to:
- Prefer **free ways first**
- Fall back to LRU only when all ways are occupied

---

### 2️⃣ Operation Decoding

The input operation is decoded into:

- `ls_rd_valid` → Read
- `ls_wr_valid` → Write
- `ls_inv_valid` → Invalidate

The encoded way input `ls_way_i` is converted into a **one-hot vector** for easier comparison and updates.

---

### 3️⃣ Pairwise Age Tracking Matrix (`track_older`)

The heart of the design is a matrix:

```
track_older[i][j] = 1  → way i is older than way j
```

Key properties:
- Diagonal entries are always `0`
- Only half the matrix is stored; the other half is inferred
- Updated whenever a way is accessed

When a way is accessed:
- That way becomes **newer than all others**
- All other ways become **older relative to it**

This efficiently maintains a total ordering of ways.

---

### 4️⃣ Oldest Way Detection

A way is considered the **oldest** if:

```
No other valid way is older than it
```

This is computed by AND’ing the `track_older` row with valid bits and checking if the result is zero.

---

### 5️⃣ Way Selection Logic

On a **write (store)** operation:

1. If **any free way exists**, select the lowest-index free way
2. Otherwise, select the **oldest valid way** (true LRU)

The result is:
- One-hot encoded
- Available in the **same cycle**

---

### 6️⃣ LRU State Updates

LRU state is updated on:
- Reads (Load)
- Writes (Store)

Invalidations:
- Do not affect relative age
- Simply mark the way as available

---

## ✅ Key Design Properties

- ✔ Parameterized for any power-of-2 number of ways
- ✔ Same-cycle LRU decision
- ✔ True LRU (not pseudo-LRU)
- ✔ One-hot output encoding
- ✔ Correct handling of invalidate operations
- ✔ No illegal way selection guaranteed by interface

---

## 📘 Learnings and Takeaways

### 🔹 True LRU Is State-Heavy but Precise

Pairwise comparison gives exact LRU behavior, at the cost of `O(N²)` state.

---

### 🔹 Availability Optimization Matters

Always picking free ways first avoids unnecessary LRU evictions and improves cache efficiency.

---

### 🔹 One-Hot Encoding Simplifies RTL

One-hot signals reduce complex comparisons and make update logic cleaner and safer.

---

### 🔹 This Is a Classic RTL Interview Problem

Understanding this design prepares you for cache, TLB, and replacement-policy questions.

---

## 🚀 Summary

This LRU module provides a **production-quality, parameterized implementation** of a true LRU replacement policy suitable for N-way set associative caches. It balances correctness, clarity, and extensibility, making it ideal for both real designs and interview discussions.

---

📂 *This README is ready to be used directly as `README.md` in a GitHub repository.*

