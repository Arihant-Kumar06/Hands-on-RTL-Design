# Skid Buffer – Ready/Valid Elastic Pipeline

## 📌 Problem Description

This project implements a **Skid Buffer**, a fundamental building block used in **Networks-on-Chip (NoC)** and **elastic pipelines** to decouple timing between modules using a **ready/valid handshake protocol**.

In a standard ready/valid interface:
- **Producer** asserts `valid` when data is available
- **Consumer** asserts `ready` when it can accept data
- A transfer happens when **both are high** on the same cycle

### Motivation

The Physical Design team reports **timing pressure on the `ready` path** between ingress and egress modules. To solve this without reducing throughput, a **skid buffer** is inserted:

- It **registers the ready signal** going back to the ingress
- It allows **one-cycle buffering** of data when the egress suddenly deasserts `ready`
- It preserves **full throughput (1 transfer per cycle)** when both sides are ready

All flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🧠 Intuition Behind the Design

Think of the skid buffer as a **one-entry safety net**.

- Normally, data flows straight through (pass-through mode)
- If the egress suddenly says "stop" (`e_ready_i = 0`) while input data is valid:
  - The skid buffer **captures that data**
  - Tells the ingress to **pause** by deasserting `i_ready_o`
  - Holds the data stable until the egress is ready again

This avoids long combinational paths while guaranteeing:

✔ No data loss  
✔ Stable data under backpressure  
✔ Same throughput as a direct connection

---

## 🏗️ Design Approach

### 1️⃣ Internal Buffer

The skid buffer uses a **single entry register**:

- `buf_valid_q` → Indicates buffered data is valid
- `buf_data_q`  → Stores buffered data

This buffer is used **only when necessary**.

---

### 2️⃣ Input Ready (`i_ready_o`)

The ingress is allowed to send data **only when the buffer is empty**:

```
i_ready_o = ~buf_valid_q
```

- Buffer empty → accept new data
- Buffer full → stall ingress

This breaks the timing dependency on `e_ready_i`.

---

### 3️⃣ When Does the Buffer Capture Data?

Data is captured into the buffer when:

- Input has valid data (`i_valid_i = 1`)
- Ingress is allowed (`i_ready_o = 1`)
- Egress **cannot** accept data (`e_ready_i = 0`)

This is the classic **skid condition**.

---

### 4️⃣ Output Valid & Data Muxing

The egress sees:

```
e_valid_o = buf_valid_q | i_valid_i
e_data_o  = buf_valid_q ? buf_data_q : i_data_i
```

Priority is always given to **buffered data**, ensuring:
- Data ordering is preserved
- Buffered transactions are drained first

---

### 5️⃣ Buffer Drain Logic

When `e_ready_i` goes high:
- Buffered data is consumed
- `buf_valid_q` is cleared
- Normal pass-through operation resumes

---

## ✅ Key Design Properties

- ✔ Registered `i_ready_o` (timing-friendly)
- ✔ One-cycle skid protection
- ✔ Full throughput when not stalled
- ✔ No data loss under backpressure
- ✔ Stable data until accepted
- ✔ Accepts data immediately after reset

---

## 📘 Learnings and Takeaways

### 🔹 Skid Buffers Are Timing Tools

They are not about storage capacity, they exist to **shorten critical paths** in high-speed designs.

---

### 🔹 Ready/Valid Protocols Require Careful Priority

Buffered data must always take precedence to avoid reordering bugs.

---

### 🔹 One Entry Is Often Enough

A single entry buffer solves most timing problems while keeping area and latency minimal.

---

### 🔹 Pass-Through When Possible

The best skid buffer behaves like a wire when both sides are ready - zero performance penalty.

---

## 🚀 Summary

This skid buffer design:
- Cleanly decouples ingress and egress timing
- Preserves handshake semantics
- Maintains maximum throughput

It is a **classic RTL interview problem** and a **production-quality NoC primitive**.



