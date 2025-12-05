# 🧮 Atomic 64-bit Counter on a 32-bit Bus  
### **A Single-Copy Atomic Read Interface for SoC Designs**

This project implements a **64-bit free-running hardware counter** that increments on every trigger pulse (`trig_i`).  
Since the processor accesses data through a **32-bit bus**, a full 64-bit value must be read in **two steps**.  
The main challenge is ensuring these two reads always return a **consistent snapshot** of the same counter value even if the counter increments between reads.

This design guarantees **single-copy atomicity**, supports **back to back bus requests**, and **never stalls the counter**.

---

## 🚀 Why This Problem Exists

Wide hardware counters (timers, PMUs, debug counters) are common in SoCs, but many embedded CPUs only support **32-bit data paths**.  
Naively reading the lower word and then the upper word can yield a **torn 64-bit value** if the counter increments between the reads.

Example of an invalid combined read:
- Lower read → `0xFFFFFFF0`  
- Upper read → `0x00000002`

This produces a 64-bit number that **never actually existed** internally.

To prevent this, silicon designs use **atomic multiword read mechanisms**, which this project implements.

---

## 🧠 Core Concept : Snapshot the Upper 32 Bits

A full 64-bit read is split into two bus requests:

### **1️⃣ Atomic read request (`atomic_i = 1`)**
- Returns **lower 32 bits**
- Saves (snapshots) the **upper 32 bits** into a shadow register (`count_msb`)

### **2️⃣ Second read request (`atomic_i = 0`)**
- Returns the **snapshotted upper 32 bits**, not the live counter value

This ensures both halves come from the **same instant in time**, guaranteeing atomicity.

---

## 🔄 Request–Acknowledge Protocol

The module uses a simple pipelined handshake:

```
req_i  → (registered) → req_q  
ack_o = req_q
```

### Protocol Guarantees
- `ack_o` asserts **exactly 1 cycle after** the request  
- Output data (`count_o`) is **valid only when `ack_o = 1`**  
- When `ack_o = 0`, output = **0** for clean bus behavior  
- Fully supports **continuous or back-to-back requests**  
- The counter **never stalls** during reads  

---

## 🛠 Internal Architecture

### **1. 64-bit Free Running Counter**
```verilog
count_q <= count_q + trig_i;
```

### **2. Shadow Register for Atomic Snapshot**
```verilog
if (atomic_q) count_msb <= count_q[63:32];
```

### **3. Output Selection Logic**
```verilog
count_o = atomic_q ? count_q[31:0] : count_msb;
```

### **4. Pipelined Control Signals**
```verilog
req_q    <= req_i;
atomic_q <= atomic_i;
```

---

## 🧩 Why This Design Matters

This project demonstrates several important SoC and digital design techniques:

- **Atomic multiword access**  
- **Shadow register snapshotting**  
- **Pipelined handshake protocols**  
- **Non-blocking counter operation**  
- **Back to back read support**

---

## 📚 What You Learn From This Project

You gain understanding in:

- Designing atomic read protocols  
- Implementing req/ack signaling  
- Handling wide counters safely  
- Aligning control + data timing  
- Writing synthesizable SystemVerilog  

---

## ✅ Summary

This project provides a clean silicon accurate method for exposing a **64-bit counter over a 32-bit bus** while preserving atomicity and correct timing.

It demonstrates core hardware design principles used in real SoC development.
