# Divide-By-Three Streaming Machine (FSM Design in SystemVerilog)

This project implements a digital machine that continuously receives a **serial binary input** and determines—in real time—whether the **number formed so far** is divisible by **3**. The number grows infinitely, but the design efficiently solves the problem using a **Finite State Machine (FSM)** without storing the full number.

---

## 1. Problem Overview

You are given a system that receives **one bit per clock cycle** (`x_i`).  
On each cycle, the new bit is **appended to the LSB** of the number formed so far:

```
new_number = (old_number << 1) + x_i
```

The machine must output `div_o = 1` **if and only if** the newly formed number  
(after including this cycle’s input bit) is **divisible by 3**.

### Key Requirements:
- Input arrives **every cycle**
- Output must be produced **in the same cycle**
- Output should be HIGH when the current number is 0
- Number grows infinitely — cannot store it
- Use **positive edge triggered flops** with **asynchronous reset**

---

## 2. The Core Challenge

The binary number keeps growing:

```
0 → 01 → 011 → 0110 → 01101 → ...
```

Storing such a number is impossible in hardware.  
However, to determine divisibility by 3, we only need:

```
N mod 3
```

Thus the challenge becomes:

> How do we compute divisibility by 3 without storing the full number?

---

## 3. Key Insight (Math Behind the FSM)

Let `r = N mod 3`.

Each new bit forms:

```
new_number = 2*N + x_i
new_r = (2*r + x_i) mod 3
```

Since `r` can only be **0, 1, or 2**, the design requires only **3 states**.

---

## 4. FSM Design

### States:
| State | Meaning |
|-------|---------|
| REM_0 | Number mod 3 = 0 |
| REM_1 | Number mod 3 = 1 |
| REM_2 | Number mod 3 = 2 |

### Transitions:
Based on `new_r = (2*r + x_i) % 3`.

### Output:
```
div_o = 1 when new remainder == 0
```

---

## 5. Learnings & Takeaways

### ✔ Minimal-State Thinking  
Store only what matters — here, just the **remainder mod 3**.

### ✔ Math → Hardware Mapping  
Binary shifting & modulo arithmetic naturally form FSM transitions.

### ✔ FSM Concepts  
- State encoding  
- Next-state logic  
- Mealy vs Moore behavior  
- Async reset  
- Sequential vs combinational logic  

### ✔ Streaming Processing  
Hardware often processes data bit-by-bit (like CRC, hashing, serial protocols).

### ✔ SystemVerilog Skills  
- `always_ff`, `always_comb`  
- Enumerated state types  
- Clean, synthesizable RTL  

---

This project shows how elegant and efficient FSM-based hardware designs can be when using mathematical insight instead of brute‑force storage.

