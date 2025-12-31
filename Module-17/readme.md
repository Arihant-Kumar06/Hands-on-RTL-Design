# Credit Deadlock – Credit & Retry Based Ring Interface

## 📌 Problem Description

This module implements a **credit-based deadlock avoidance interface** for a **unidirectional ring-based NoC**. The original ring used a standard **valid–ready protocol**, which caused severe performance degradation when a slow target device blocked the ring for hundreds of cycles.

To meet a strict performance requirement, i.e **no transaction may be stalled for more than 3 cycles**, the protocol is upgraded to include:
- **Retry signaling** (instead of indefinite stalling)
- **Credit-based re-issuance** of retried requests
- **Throttling** after excessive retries

The goal of this module is to **bridge a credit+retry protocol on the RX side** with a **standard valid–ready protocol on the TX side**, while ensuring forward progress and avoiding deadlock.

---

## 🧠 Intuition Behind the Design

The root cause of the performance problem is **head-of-line blocking**:
- A slow transaction occupies the ring
- All following transactions are blocked
- System throughput collapses

The fix is to **never let a request block the ring for too long**.

Key ideas:
- If a request cannot be accepted within **3 cycles**, issue a **retry**
- Retried requests are **removed from the ring**
- They may re-enter only after a **credit is granted**
- Credits are issued when **buffer space becomes available**

This guarantees:
> ✔ No transaction blocks the ring for more than 3 cycles  
> ✔ Deadlock freedom  
> ✔ Fair progress across devices

---

## 🏗️ Design Approach

### 1️⃣ RX Buffering (Request FIFO)

- Incoming RX requests are stored in a FIFO (depth ≥ 4)
- FIFO decouples RX arrival from TX acceptance
- RX ordering is preserved unless a retry occurs

This buffering absorbs short-term backpressure from the TX side.

---

### 2️⃣ 3-Cycle Deadlock Detection

A **deadlock counter** tracks how long the RX side is stalled:

- Counter increments when RX is valid but FIFO is full
- If stall persists for **3 cycles**, a retry is issued
- Counter resets when progress is made

This enforces the performance requirement strictly.

---

### 3️⃣ Retry Handling

When a retry is issued:
- RX request is **not accepted**
- Request ID is stored in a **retry FIFO**
- That request is guaranteed to be retried **only once** (per spec)

Requests with `rx_credit_i = 1` are **never retried again**.

---

### 4️⃣ Credit Grant Mechanism

Credits are granted when:
- Buffered requests are drained toward TX
- FIFO space becomes available

A **credit FIFO** tracks which request IDs are waiting for credits.

- `credit_gnt_o` is asserted when a credit is issued
- Credits are always accepted (no ready signal)

This enables safe re-entry of retried transactions.

---

### 5️⃣ Throttling After Excessive Retries

To prevent pathological behavior:
- A reservation counter (`rsv_count_q`) tracks outstanding retried requests
- If **4 retries occur without credit release**, RX is throttled
- RX resumes only after credits are granted

This protects the ring from retry storms.

---

### 6️⃣ TX Side Interface (Valid–Ready)

- RX FIFO feeds TX through a **skid buffer**
- Preserves valid–ready semantics
- Ensures clean timing closure and ordering

TX always sees requests in-order except when retries intervene.

---

## ✅ Key Design Properties

- ✔ Guaranteed progress (no >3 cycle stall)
- ✔ Deadlock-free operation
- ✔ RX ordering preserved (except retries)
- ✔ Credit-based fairness
- ✔ Throttling after 4 retries
- ✔ Compatible with legacy valid–ready targets

---

## 📘 Learnings and Takeaways

### 🔹 Head-of-Line Blocking Is Deadly in Rings

Ring topologies amplify stalls, one blocked node can freeze the system.

---

### 🔹 Retry + Credit Is a Powerful Pattern

This pattern is widely used in:
- High-performance NoCs
- PCIe
- AXI-based fabrics

---

### 🔹 Bounded Stall Guarantees Matter

Architectural guarantees ("≤3 cycles") dramatically simplify system-level performance analysis.

---

### 🔹 Throttling Is as Important as Retry

Without throttling, retry mechanisms can destabilize the system.

---

## 🚀 Summary

This Credit Deadlock module provides a **robust, performance-guaranteed interface** for ring-based NoCs by combining buffering, retry, credit, and throttling mechanisms. It eliminates head-of-line blocking while maintaining protocol correctness and fairness, a production-grade solution for scalable interconnects.

