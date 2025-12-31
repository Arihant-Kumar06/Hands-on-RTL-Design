# Async Reset – Safe Reset Deassertion & Clock Gating

## 📌 Problem Description

This module is designed to **avoid boot-up issues in silicon** caused by unsafe deassertion of an **asynchronous reset**.

In real chips, reset and clock signals are distributed through separate trees and reach different flops at **different times**. If reset is released too early or clocks start toggling before reset is fully stable, the circuit can enter **metastable or illegal states**.

To prevent this, the module:
- Synchronizes the asynchronous reset to the clock domain
- Ensures reset is released **only after it has been low for a safe duration**
- Gates the clock during the unsafe window

---

## 🔌 Interface Definition

### Inputs
- `clk` : System clock
- `reset` : Asynchronous active-high reset

### Outputs
- `release_reset_o` : Indicates it is safe to release reset to the rest of the circuit
- `gate_clk_o` : Clock gate control for downstream logic

---

## 📐 Design Constraints & Specifications

- Reset must be **low for at least 5 cycles** before being released
- Clock tree latency: **7 cycles**
- Reset tree latency: **8 cycles**
- All flops must be **positive-edge triggered with async reset**

These constraints mean reset must be held **longer than the clock**, ensuring reset reaches all flops before clocks start toggling.

---

## 🧠 Intuition Behind the Design

The key idea is:

> *Never allow the clock to run or reset to be released until the reset signal is stable and fully propagated.*

To achieve this:
- A **counter** is loaded on reset assertion
- The counter decrements only after reset is deasserted
- Different counter thresholds are used to:
  - Enable clock safely
  - Release reset safely

This enforces **temporal separation** between reset deassertion, clock enabling, and reset release.

---

## 🏗️ Design Approach

### 1️⃣ Reset Countdown Counter

- A 5-bit counter `cnt_q` is initialized to a non-zero value on reset
- Once reset goes low, the counter decrements every cycle
- When the counter reaches zero, the system is fully out of reset

This counter acts as a **time buffer** to absorb reset/clock skew.

---

### 2️⃣ Clock Gating Logic (`gate_clk_o`)

```
gate_clk_o = (cnt_q < 14) & (cnt_q != 0)
```

Meaning:
- Clock remains gated initially
- Clock is enabled **after reset tree has settled**
- Clock is disabled again only when fully out of reset

This ensures clocks never toggle when reset may still be unstable.

---

### 3️⃣ Safe Reset Release (`release_reset_o`)

```
release_reset_o = (cnt_q < 8)
```

Meaning:
- Reset is released only after:
  - Reset has been low for ≥5 cycles
  - Reset tree delay (8 cycles) is satisfied

This guarantees reset reaches **all flops** before deassertion.

---

## 🔁 Timeline Interpretation

| Phase | Counter | Behavior |
|------|--------|---------|
| Reset asserted | Loaded | Clock gated, reset held |
| Reset deasserted | Count down | Clock still gated |
| cnt < 14 | | Clock ungated |
| cnt < 8 | | Reset safely released |
| cnt = 0 | | Normal operation |

---

## ✅ Key Design Properties

- ✔ Safe asynchronous reset deassertion
- ✔ Protection against reset/clock skew
- ✔ No metastability risk on startup
- ✔ Simple, synthesizable logic
- ✔ Matches physical design constraints

---

## 📘 Learnings and Takeaways

### 🔹 Reset Is a Physical Problem, Not Just Logical

Clock and reset trees behave differently, RTL must respect that reality.

---

### 🔹 Counters Are Powerful Safety Tools

Simple counters can enforce complex timing guarantees.

---

### 🔹 Clock Gating During Reset Is Essential

Allowing clocks to toggle before reset settles is a common silicon bug source.

---

### 🔹 Always Design for Worst-Case Delays

Using reset-tree and clock-tree latency ensures robust boot behavior.

---

## 🚀 Summary

This Async Reset module provides a **robust, silicon-safe mechanism** to synchronize and release asynchronous resets while properly gating clocks. It bridges the gap between RTL design and physical implementation realities, making it a critical building block for reliable SoC boot-up.



