# 🧮 Atomic 64-bit Counter over a 32-bit Bus  
### *Single-Copy Atomic Read Interface for SoC Designs*

This project implements a **64-bit hardware event counter** that increments on every trigger pulse (`trig_i`).  
The counter is exposed to a processor via a **32-bit bus**, meaning software must perform **two 32-bit reads** to obtain the full counter value.

The primary challenge is ensuring that the two reads return a **consistent snapshot** of the counter — even if the counter increments between the reads.  
This design guarantees **single-copy atomicity**, supports **back-to-back requests**, and **never stalls the counter**.

---

## 🔧 Problem Motivation  

Wide registers (e.g., 64-bit time counters, PMU counters, free-running timers) are common in SoC hardware.  
But embedded processors often read them through a **32-bit bus**, forcing multi-step read operations.

A naïve two-step read can accidentally produce a **torn value**:

Lower read: 0xFFFFFFF0 (low part of 0x00000001_FFFFFFF0)
Upper read: 0x00000002 (high part of 0x00000002_00000030)


This combined value **never existed** in the counter.

To prevent this, hardware designers use **atomic read protocols**, one of which is implemented here.

---

## 🧠 Core Idea — Snapshot the Upper 32 Bits  

A full 64-bit read is split across two requests:

### **1. First read request (`atomic_i = 1`):**
- Returns **lower 32 bits** of the counter.  
- **Snapshots the upper 32 bits** into a shadow register (`count_msb`).

### **2. Second read request (`atomic_i = 0`):**
- Returns the **snapshotted upper 32 bits**, not the live counter value.

This guarantees that both reads correspond to the **same 64-bit value**, regardless of counter increments between them.

This is a widely used industry pattern for exposing wide counters through narrow buses.

---

## 🔄 Request–Acknowledge Protocol  

The module uses a simple pipelined handshake:

req_i (input) → registered → req_q
ack_o = req_q


### Guarantees:
- `ack_o` asserts **exactly one cycle after** the request.
- `count_o` is valid **only when `ack_o = 1`**.
- When `ack_o = 0`, output data is **0**, ensuring clean bus behavior.
- Supports **pulsed** or **back-to-back** requests without hazards.

---

## 🛠 Internal Design Structure  

### ✔ 1. 64-bit Free-Running Counter
```verilog
count_q <= count_q + trig_i;

2. Snapshot Register for Atomicity

Captures the upper 32 bits on the first read:

if (atomic_q) count_msb <= count_q[63:32];

3. Output MUX Logic

If atomic_q = 1 → output lower 32 bits

If atomic_q = 0 → output snapshotted upper bits

count_o = atomic_q ? count_q[31:0] : count_msb;

✔ 4. Synchronous, Pipelined Design

Control signals (req_i, atomic_i) are registered to maintain timing alignment:

req_q    <= req_i;
atomic_q <= atomic_i;

This ensures the output and acknowledgement always correspond to the right phase of the protocol.

🧩 Why This Design Matters

This module showcases several real-world hardware concepts used in industry SoC designs:

🔹 1. Atomic Multiword Access

A robust method to read a wide register over a narrower bus without tearing.

🔹 2. Shadow Register Technique

Used in CPUs, PMUs, timers, and debug logic to ensure consistency.

🔹 3. Pipelined Control Alignment

Control inputs are delayed by one cycle to match data and handshake timing.

🔹 4. Non-Blocking Counter Operation

The counter continues incrementing even during atomic reads.

🔹 5. Back-to-Back Request Handling

No need for stalls or large state machines — simple pipelining is enough.

📚 Key Learnings

This exercise provides practical experience with:

Designing single-copy atomic read mechanisms

Exposing 64-bit hardware counters via 32-bit interfaces

Implementing req/ack bus protocols

Using snapshot registers for consistency

Aligning control and data paths in synchronous systems

Writing clean, verifiable hardware logic (SystemVerilog)

These are foundational concepts for:

SoC architecture

Bus protocol design

Performance monitoring units

Hardware abstraction layers

✔ Summary

This project demonstrates a clean and hardware-accurate method to provide atomic access to a 64-bit counter on a 32-bit bus.
It highlights critical SoC design principles including pipelining, atomicity, register snapshotting, and deterministic acknowledge behavior.

These techniques translate directly to real-world silicon development, making this a strong learning and portfolio piece.