# 🧩 3-Bit Palindrome Detector (Streaming RTL Design)

## 📌 Overview
This project implements a **3-bit palindrome detector** for a **continuous serial stream of input bits**.
At **every clock cycle**, the circuit determines whether the **current input bit and the previous two bits**
together form a **palindrome**.

A palindrome is a sequence that reads the same **forward and backward**.

### Examples of valid 3-bit palindromes
```
000, 010, 101, 111
```

The design is **fully streaming**, meaning:
- One input bit is accepted per cycle
- Output is generated **every cycle**
- No stalling or buffering of the input stream

---

## 🧠 Problem Statement
Design a circuit that:
- Accepts a serial input stream of bits
- Detects whether the **last three bits** form a palindrome
- Produces an output **on every clock cycle**
- Uses **positive edge-triggered flip-flops**
- Uses **asynchronous reset**

---

## 🔌 Interface Definition

| Signal | Direction | Description |
|------|----------|-------------|
| clk | Input | Clock |
| reset | Input | Asynchronous active high reset |
| x_i | Input | Serial input bit |
| palindrome_o | Output | High when last 3 bits form a palindrome |

---

## 🏗️ Design Approach

### Key Observations
- A 3-bit palindrome only requires checking:
  `first_bit == last_bit`
- The middle bit does not affect palindromicity
- Output must be suppressed until at least 3 bits are received

### Architecture
- **2-bit shift register** to store the last two bits
- **2-bit saturating counter** to track valid input cycles
- **Combinational comparison logic** for palindrome detection

---


## ✅ Why This Design Works
- Output is produced **every cycle**
- Reset behavior is safe and deterministic
- Minimal hardware usage
- Fully synthesizable RTL
- Interview grade coding style

---

## 🎯 Learnings & Takeaways
- Shift registers are fundamental for streaming problems
- Counters can be used as valid data indicators
- Palindrome detection does not require storing full sequences
- Clean separation of sequential and combinational logic improves reliability

---

## 🧠 Final Note
This project demonstrates **core RTL streaming design concepts** and is suitable for:
- Digital design interviews
- Coursework submissions
- GitHub hardware portfolios
