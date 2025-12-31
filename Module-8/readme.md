# Low Power Channel (ARM Q Channel Integration)

## 📌 Problem Description
This project implements a **Low Power Channel** module that integrates the **ARM Q-channel protocol** to safely manage power state transitions between an upstream producer and an internal consumer.

The core challenge is to:
- Safely enter a **low power state** without losing write data
- Correctly follow the **QREQn / QACCEPTn / QACTIVE** handshake semantics
- Ensure all pending writes are flushed and completed before power down
- Resume normal operation cleanly on wakeup

A FIFO of **minimum depth 6** is used to buffer writes and prevent data loss during power transitions.

---

## 🧠 Intuition Behind the Design

Power transitions are dangerous because:
- Upstream logic may still be generating data
- Internal logic may stop accepting data during low power mode

The intuition is to:
1. **Buffer all writes** in a FIFO
2. **Request upstream to flush** when a low power request arrives
3. **Wait until FIFO is empty and writes are done**
4. **Acknowledge power down** only when the system is safe

This ensures:
> ⚠️ *No write data is dropped and protocol rules are respected*

---

## 🏗️ Design Approach

### 1️⃣ FIFO Based Data Protection
- A `qs_fifo` of **depth 6** buffers all write data
- Writes (`wr_valid_i`) always push into FIFO
- Reads (`rd_valid_i`) pop data from FIFO

This decouples upstream and downstream activity during power transitions.

---

### 2️⃣ Q-Channel State Machine

A 4-state FSM manages the Q channel handshake:

| State | Meaning |
|------|--------|
| `ST_Q_RUN` | Normal operation |
| `ST_Q_REQUEST` | Low power requested (QREQn low) |
| `ST_Q_STOPPED` | Device safely in low power |
| `ST_Q_EXIT` | Exiting low power |

**State Transitions**:
- `RUN → REQUEST` when `QREQn` goes low
- `REQUEST → STOPPED` when `QACCEPTn` is asserted
- `STOPPED → EXIT` when `QREQn` goes high
- `EXIT → RUN` when `QACCEPTn` is deasserted

---

### 3️⃣ QACCEPTn Generation

`QACCEPTn` is asserted **only when it is safe**:

✔ FIFO is empty  
✔ Upstream has completed all pending writes (`wr_done_i`)  
✔ A low power request is active (`QREQn = 0`)

This strictly follows ARM Q channel protocol expectations.

---

### 4️⃣ Flush Mechanism

When a low power request arrives:
- `wr_flush_o` is asserted
- Upstream is instructed to stop and flush writes
- Flush remains active until `wr_done_i` is seen

This guarantees all outstanding writes are accounted for.

---

### 5️⃣ QACTIVE Logic

`QACTIVE` indicates whether the module is still doing useful work.

It is asserted when:
- FIFO is non empty
- A read or write is active
- A wakeup request is received (`if_wakeup_i`)

This prevents premature power down.

---

## ✅ Key RTL Decisions

- **Asynchronous reset** on all flops (per requirement)
- **No write drops** guaranteed via FIFO buffering
- **QACCEPTn deasserted out of reset**
- `wr_done_i` sampled only outside low power state

---

## 📘 Learnings and Takeaways

### 🔹 Protocol Awareness Matters
Power protocols are not just signals — they encode **system-level safety guarantees**.

---

### 🔹 FSM + Handshake = Robust Design
Using a clean FSM made it easy to:
- Enforce ordering rules
- Avoid illegal transitions
- Debug protocol behavior

---

### 🔹 Buffering is the Key to Low Power Safety
A sufficiently deep FIFO:
- Decouples producer/consumer timing
- Enables graceful power transitions
- Prevents silent data loss

---

### 🔹 QACTIVE is as Important as QACCEPT
Many bugs arise when QACTIVE is deasserted too early. Tracking *real work* avoids this.

---

## 🚀 Summary

This design demonstrates a **production quality integration of ARM Q channel** with:
- Safe data handling
- Clean power transitions
- Protocol compliant signaling

It is a strong example of **low-power aware RTL design** suitable for SoCs and IP blocks.



