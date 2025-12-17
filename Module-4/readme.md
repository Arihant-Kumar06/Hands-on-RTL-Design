# Sequence Generator (Hardware Design)

## 📌 Problem Overview

Design a hardware sequence generator that produces the following infinite sequence, one value per clock cycle:

```
0 → 1 → 1 → 1 → 2 → 2 → 3 → 4 → 5 → 7 → 9 → 12 → 16 → 21 → 28 → 37 → ...
```

### Key Requirements
- Output must be produced **every cycle**
- Sequence runs indefinitely until reset
- All flip flops must be **positive edge triggered**
- Reset (if any) must be **asynchronous**
- No overflow handling is required (assume sufficient bit width)

---

## 🧠 Sequence Insight

This is a **Fibonacci like recurrence** defined as:

```
term(n) = term(n−3) + term(n−2)
```

To generate this in hardware, we must **retain history**. Specifically, we need to remember the last **three** terms at all times.

---

## 🏗️ Design Approach

### Core Idea
Use a **3-stage shift register** where:
- Each register stores one term of the sequence
- On every clock cycle, registers shift forward
- The next term is computed using older values

### Register Roles

| Register | Purpose |
|--------|--------|
| seq_t3 | Oldest value (current output) |
| seq_t2 | Middle value |
| seq_t1 | Most recent value |

---

## 📤 Output Logic Explanation

The output is taken from `seq_t3` because:
- It holds the **oldest committed value**
- It is always valid immediately after reset
- It avoids off-by-one and look-ahead timing errors

This guarantees **one correct output per cycle**, as required.

---

## 🎯 Learnings & Takeaways

- Hardware sequences require **explicit state storage**
- Reset values define correctness of the entire sequence
- Separating combinational and sequential logic improves clarity
- Shift-register-based designs are common in CPUs, DSPs, and SoCs
- Output should come from a **fully registered, stable stage**

---

## ❓ Common Questions

### 1. Why 3 registers and not 2?
Because the recurrence depends on `term(n−3)` and `term(n−2)`. Two registers cannot store sufficient history to compute the next value correctly.

---

### 2. What happens if reset is synchronous instead?
With synchronous reset, the output may be invalid during the first active clock edge. Asynchronous reset ensures the sequence starts in a known, valid state immediately.

---

### 3. Can this be generalized to N-term sequences?
Yes. Use an N-stage shift register and compute:
```
next = sum of selected previous terms
```
This is commonly used in filters and predictors.

---

### 4. How would you optimize area?
- Reduce bit-width if overflow bounds are known
- Use fewer registers if recurrence allows
- Share adders using time-multiplexing (at cost of throughput)

---

### 5. How would you test this using a testbench?
- Apply reset and verify initial outputs
- Compare generated values against a golden model
- Run for many cycles to ensure stability

---

### 6. What happens if overflow occurs?
If overflow is not handled, the sequence wraps around due to modulo arithmetic. In real designs, saturation logic or wider registers would be used.

---

## 🧪 Suggested Enhancements

- Add SystemVerilog Assertions (SVA)
- Parameterize register width
- Create a self-checking testbench
- Extend to configurable N-term generators

---

## 🏁 Final Notes

This problem tests **RTL fundamentals**, including:
- Sequential logic
- Reset discipline
- Timing alignment
- Pipeline-style thinking

A strong grasp of this design translates directly to real-world hardware design tasks.
