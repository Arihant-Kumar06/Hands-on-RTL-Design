# One Shot – Positive Edge Detector

## 📌 Problem Description

This module implements a **one-shot circuit** that detects a **positive edge (0 → 1 transition)** on a single-bit input signal `data_i`.

Whenever a positive edge is detected, the output `shot_o` is asserted for **exactly one clock cycle**, regardless of how long the input stays high afterward.

Such circuits are widely used when logic must react **once** to a control event, handshake completion, interrupt trigger, or state transition.

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Definition

- **Input**
  - `data_i` : Input control signal

- **Output**
  - `shot_o` : One-cycle pulse asserted on a positive edge of `data_i`

---

## ✅ Interface Requirements

- Output goes high **for one cycle only** when a pos-edge is detected
- Output is produced **every cycle**
- No pulses are generated if `data_i` remains high
- Circuit must work correctly across multiple rising edges

---

## 🧠 Intuition Behind the Design

The key idea is simple:

> To detect a rising edge, compare the **current value** of a signal with its **previous value**.

A positive edge occurs when:

```
Previous = 0  AND  Current = 1
```

So we need:
1. A register to **remember the previous value** of `data_i`
2. Combinational logic to detect `0 → 1`
3. A pulse that lasts exactly **one clock cycle**

---

## 🏗️ Design Approach

### 1️⃣ Previous State Register

A flip-flop `data_q` stores the value of `data_i` from the previous cycle.

- Updated every clock cycle
- Reset initializes it to `0`

This gives us a clean reference for edge detection.

---

### 2️⃣ Positive Edge Detection Logic

A rising edge is detected using simple combinational logic:

```
shot_o = data_i & ~data_q
```

This expression is true **only in the cycle where `data_i` transitions from 0 to 1**.

---

### 3️⃣ One-Cycle Pulse Guarantee

- On the edge cycle → `data_i = 1`, `data_q = 0` → `shot_o = 1`
- On the next cycle → `data_q` updates to `1` → `shot_o = 0`

Thus, the output is **automatically self-clearing** after one cycle.

---

## 🔁 Sample Behavior Walkthrough

| Cycle | data_i | data_q | shot_o | Explanation |
|-----|-------|--------|--------|-------------|
| T3 | 0 | 0 | 0 | Idle |
| T4 | 1 | 0 | 1 | Positive edge detected |
| T5 | 1 | 1 | 0 | Held high, no new edge |
| T6 | 0 | 1 | 0 | Falling edge ignored |
| T8 | 1 | 0 | 1 | New positive edge |

---

## ✅ Key Design Properties

- ✔ Single-cycle pulse generation
- ✔ No false triggers on steady high input
- ✔ Fully synchronous logic
- ✔ Minimal hardware (1 FF + 1 gate)
- ✔ Robust and deterministic behavior

---

## 📘 Learnings and Takeaways

### 🔹 Edge Detection Requires State

You cannot detect an edge without remembering the past. One flip-flop is the minimum state required.

---

### 🔹 One-Shot Pulses Are Safer Than Level Signals

Pulse-based signaling avoids repeated triggering and simplifies downstream logic.

---

### 🔹 This Is a Fundamental RTL Building Block

One-shot circuits appear in:
- Interrupt detection
- FSM transitions
- Handshake protocols
- Control and sequencing logic

Mastering this pattern is essential for solid RTL design.

---

## 🚀 Summary

This **One Shot** module is a clean and minimal implementation of a **positive edge detector** that generates a one-cycle pulse. It is simple, robust, and widely applicable in real hardware designs and RTL interviews.


