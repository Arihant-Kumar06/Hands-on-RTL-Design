# Ordering Buffer – Ordered & Unordered Request Handling

## 📌 Problem Description

This module implements an **ordering-aware request buffer** that sits between an incoming **RX valid–ready interface** and an outgoing **TX valid–ready interface**.

Each request entering the RX interface can be either:
- **Unordered** → may be sent to TX as soon as it retires
- **Ordered** → may be sent to TX **only after all earlier requests** have been sent on TX

The buffer must:
- Hold **exactly 8 requests**
- Support **out-of-order retire** events
- Enforce strict ordering constraints for ordered requests
- Meet a **performance guarantee**: once an unordered request retires, a TX valid must be issued **in the very next cycle**

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Overview

### RX Interface (Ingress)
- `rx_valid_i` : Incoming request valid
- `rx_id_i` : Unique request ID
- `rx_payload_i` : Request payload
- `rx_order_i` : Ordering attribute (1 = ordered, 0 = unordered)
- `rx_ready_o` : Buffer ready

### RX Retire Interface
- `rx_ret_i` : Retire indication
- `rx_ret_id_i` : ID of retired request

### TX Interface (Egress)
- `tx_valid_o` : Outgoing request valid
- `tx_id_o` : Request ID
- `tx_payload_o` : Request payload
- `tx_ready_i` : Downstream ready

---

## 🧠 Intuition Behind the Design

This problem is fundamentally about **decoupling completion order from issue order** while still respecting ordering rules.

Key challenges:
- Requests can **retire out-of-order**
- Ordered requests impose **global constraints**
- Unordered requests must not be delayed unnecessarily

The key insight is:

> Maintain a table of in-flight requests and track **relative age** between them.

This allows the design to:
- Identify the **oldest eligible retired request** every cycle
- Issue TX requests without violating ordering
- Achieve the required next-cycle performance for unordered requests

---

## 🏗️ Design Approach

### 1️⃣ Request Table (8 Entries)

The design uses a fixed-size **request table** with 8 entries. Each entry stores:
- Request ID
- Payload
- Retired flag
- In-order flag

An availability bitmap tracks which entries are free.

---

### 2️⃣ RX Acceptance Logic

- RX requests are accepted into the **first available entry**
- `rx_ready_o` is asserted whenever any entry is free
- IDs may be reused after retirement (as allowed by spec)

---

### 3️⃣ Retire Tracking

- Retire events mark the corresponding table entry as `retired`
- Retires may occur **out-of-order**
- Retire does *not* immediately free the entry

---

### 4️⃣ Age & Ordering Tracking

A **pairwise age matrix (`track_older`)** tracks relative ordering between entries:

```
track_older[i][j] = 1  → entry i is older than entry j
```

Rules:
- Only ordered requests participate in strict ordering
- Unordered requests can bypass younger ordered requests

This mechanism allows identification of the **oldest eligible request**.

---

### 5️⃣ TX Selection Logic

Each cycle:
1. Find entries that are **valid + retired**
2. Among them, select the **oldest eligible entry**
3. Present it to TX through a **skid buffer**

This ensures:
- In-order TX issue for ordered requests
- Immediate issue of retired unordered requests

---

### 6️⃣ Entry Release

- An entry is freed **only after TX handshake completes**
- This guarantees correctness even when TX is stalled

---

## ✅ Key Design Properties

- ✔ Exact 8-entry buffering
- ✔ Strict ordering enforcement
- ✔ Out-of-order retirement support
- ✔ One-cycle response for retired unordered requests
- ✔ Back-to-back RX and TX transactions
- ✔ Clean valid–ready semantics via skid buffer

---

## 📘 Learnings and Takeaways

### 🔹 Ordering Is a Global Property

Once ordering is introduced, every request must be reasoned about relative to all others.

---

### 🔹 Pairwise Age Tracking Is Powerful

Though state-heavy, it provides precise control and is commonly used in schedulers and reorder buffers.

---

### 🔹 Decoupling Retire and Issue Improves Performance

Allowing retire to occur independently avoids head-of-line blocking.

---

### 🔹 This Is Essentially a Mini Reorder Buffer (ROB)

The design closely mirrors CPU ROB logic, a valuable mental model for interviews and real designs.

---

## 🚀 Summary

This Ordering module delivers a **high-performance, ordering-correct buffering solution** between RX and TX interfaces. By combining table-based storage, age tracking, and careful TX arbitration, it meets strict performance guarantees while enforcing correctness — a production-grade solution inspired by modern CPU and NoC designs.

