# Buffering – AXI Stream to Valid-Ready Bridge with Device-Aware Buffering

## 📌 Problem Description

This module bridges an **incoming AXI Stream interface** to an **outgoing valid-ready interface**, while handling a special case where one target device (Device ID = **5**) can dynamically be in **OFF mode**.

In a naïve design, if requests targeting device 5 are stalled while the device is OFF, they would **block all subsequent AXI stream traffic**, even for devices that are always ON. This leads to unnecessary backpressure and system-level deadlocks.

To solve this, the module:
- Buffers AXI stream transfers targeting **device ID 5** when the device is OFF
- Allows requests for all other devices to continue flowing normally
- Flushes buffered requests once device 5 transitions back to ON mode

The buffer must be able to store **at least 8 requests** for device ID 5.

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Overview

### Incoming AXI Stream Interface
- `req_tvalid_i` : AXI stream valid
- `req_tid_i[2:0]` : Device ID
- `req_tdata_i[15:0]` : Payload (address on beat-0, data on beat-1)
- `req_tready_o` : AXI stream ready

Each AXI transfer consists of **two beats**:
1. Beat-0 → Address
2. Beat-1 → Data

---

### Outgoing Valid-Ready Interface
- `dev_valid_o` : Transaction valid
- `dev_addr_o[18:0]` : Address = `{address[15:0], device_id[2:0]}`
- `dev_data_o[15:0]` : Data payload
- `dev_ready_i` : Target device ready

---

### Device Status Interface
- `dev_opmode_i` : Operating mode for device ID 5
  - `1` → ON
  - `0` → OFF

This signal only changes when **no traffic is active** on either interface.

---

## 🧠 Intuition Behind the Design

The core challenge is **decoupling traffic for a single slow / OFF device from the rest of the system**.

Key ideas:
- AXI stream is **strictly ordered** and cannot skip transfers
- Valid-ready interface requires **full request assembly** before issuing
- Device ID 5 can block progress indefinitely if not handled carefully

The insight is:

> Buffer only the requests that *must* be stalled (device 5 when OFF), and let all other traffic bypass the buffer.

This ensures:
- No head-of-line blocking
- Continuous progress for always-ON devices
- Bounded buffering for the OFF device

---

## 🏗️ Design Approach

### 1️⃣ Two-Beat AXI Stream Handling

A small FSM assembles each AXI stream transfer:

| State | Meaning |
|-----|--------|
| `ST_IDLE` | Waiting for address beat |
| `ST_DATA` | Waiting for data beat |
| `ST_XFER` | Presenting request to valid-ready interface |

The FSM guarantees:
- Address and data are captured correctly
- Only one transfer is active at a time

---

### 2️⃣ Selective Buffering for Device ID 5

- Requests with `req_tid_i == 5` **and** `dev_opmode_i == 0` (OFF):
  - Are pushed into an **8-entry FIFO**
- Requests for all other devices bypass the FIFO

This prevents device 5 from stalling unrelated traffic.

---

### 3️⃣ FIFO Drain Logic

When device 5 transitions to ON mode:
- Buffered requests are drained from the FIFO
- Drained requests are injected into the same FSM path as live AXI traffic

Drain continues until the FIFO is empty.

---

### 4️⃣ Address Formation

The outgoing address is formed as:

```
dev_addr_o = {address_from_axi[15:0], device_id[2:0]}
```

This is captured during the first AXI beat and held stable until transfer completes.

---

### 5️⃣ Backpressure Handling

- AXI stream `tready` is asserted only when the FSM can accept data
- FIFO backpressure applies **only** when buffering device 5 requests
- Valid-ready backpressure (`dev_ready_i`) stalls only the final transfer stage

---

## ✅ Key Design Properties

- ✔ Prevents deadlock caused by OFF device
- ✔ Buffers at least 8 requests for device ID 5
- ✔ No buffering penalty for other devices
- ✔ Correct AXI stream two-beat handling
- ✔ Clean valid-ready semantics
- ✔ Deterministic behavior during device mode changes

---

## 📘 Learnings and Takeaways

### 🔹 Selective Buffering Beats Global Stalling

Buffering only the problematic traffic avoids unnecessary performance loss.

---

### 🔹 AXI Stream Requires Stateful Assembly

Multi-beat transfers naturally map to small FSMs.

---

### 🔹 Device-Aware Flow Control Is Essential

Ignoring device state can easily lead to deadlocks in heterogeneous systems.

---

### 🔹 FIFO + FSM Is a Powerful Pattern

This combination shows up frequently in SoC interconnects and bridges.

---

## 🚀 Summary

This Buffering module provides a **robust, performance-optimized bridge** between AXI Stream and valid-ready protocols while safely handling a dynamically OFF device. By isolating problematic traffic using targeted buffering, the design guarantees forward progress and avoids system-level deadlocks — a pattern widely applicable in real SoC interconnect designs.

---

📂 *This README is ready to be used directly as `README.md` in a GitHub repository.*