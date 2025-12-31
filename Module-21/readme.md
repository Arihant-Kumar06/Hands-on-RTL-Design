# FIFO Flush – Asymmetric FIFO with Flush Support

## 📌 Problem Description

This module implements a **FIFO with asymmetric data widths** and **flush capability**. The FIFO accepts **4-bit writes** on the write interface and produces **32-bit reads** on the read interface. In addition to normal FIFO operation, the read side can issue a **flush request** to force all currently available data to be drained, even if a full 32-bit word has not yet been accumulated.

The FIFO is sized to hold **exactly 128 bits** of data and must support concurrent writes while a flush operation is in progress.

All flip-flops are **positive-edge triggered** with **asynchronous reset**.

---

## 🔌 Interface Overview

### Write Interface
- `fifo_wr_valid_i` : Indicates 4-bit write data is valid
- `fifo_wr_data_i[3:0]` : Write data

### Read Interface
- `fifo_data_avail_o` : Indicates a read can be issued
- `fifo_rd_valid_i` : Read request (32-bit)
- `fifo_rd_data_o[31:0]` : Read data

### Flush Interface
- `fifo_flush_i` : Flush request from read side
- `fifo_flush_done_o` : Indicates flush completion

### Status Signals
- `fifo_empty_o` : FIFO empty
- `fifo_full_o` : FIFO full

---

## ✅ Interface Requirements Recap

- FIFO stores exactly **128 bits**
- Read data width is **32 bits**, write width is **4 bits**
- Flush drains **all data written up to and including the flush cycle**
- Partial data during flush may be padded with **0xC**
- New writes during flush are allowed but **must not be flushed**
- Flush remains asserted until `fifo_flush_done_o` is seen
- Output data must be valid **in the same cycle** as read request

---

## 🧠 Intuition Behind the Design

This problem combines three challenges:
1. **Width conversion** (4-bit writes → 32-bit reads)
2. **Circular buffering** with exact storage constraints
3. **Flush semantics** that cut across normal FIFO behavior

The key insight is to organize storage as **rows of 32-bit words**, each composed of **eight 4-bit nibbles**. A flush then becomes a controlled draining of these rows, with optional padding for incomplete rows.

---

## 🏗️ Design Approach

### 1️⃣ FIFO Organization

- FIFO storage is organized as **4 rows × 32 bits = 128 bits**
- Each row contains 8 nibbles written sequentially
- Write pointers:
  - `wr_row_ptr_q` selects the 32-bit row
  - `wr_col_ptr_q` selects the nibble within the row

This structure naturally bridges the 4-bit write / 32-bit read mismatch.

---

### 2️⃣ Write Logic

- Each valid write stores one nibble into the current row/column
- Column pointer increments on every write
- When the column pointer wraps, the row pointer increments

Write requests are guaranteed not to occur when FIFO is full.

---

### 3️⃣ Read Logic

- Reads always output a full 32-bit row
- `fifo_data_avail_o` is asserted when at least one row is readable or a flush is active
- Read pointer advances only when `fifo_rd_valid_i` is asserted

---

### 4️⃣ Flush Handling

When `fifo_flush_i` is asserted:
- Current write pointers are **snapshotted** as flush boundaries
- FIFO enters flush mode (`fifo_flush_q`)
- Rows are drained up to the snapshot point

For the final partial row:
- Unwritten nibbles are padded with **4'hC**

Flush completes when the read pointer reaches the snapshotted boundary.

---

### 5️⃣ Concurrent Writes During Flush

- New writes are allowed while flush is active
- Writes after the flush cycle advance normal write pointers
- Flush boundary pointers ensure **new data is not flushed**

This decouples flush servicing from ongoing writes.

---

### 6️⃣ Full / Empty Detection

- FIFO empty when read and write pointers match and no partial row exists
- FIFO full when write pointer wraps around read pointer

These conditions ensure exact **128-bit capacity enforcement**.

---

## ✅ Key Design Properties

- ✔ Asymmetric FIFO (4-bit → 32-bit)
- ✔ Exact 128-bit storage
- ✔ Flush with precise boundary semantics
- ✔ Padding support for partial data
- ✔ Concurrent write support during flush
- ✔ Zero-cycle latency on reads

---

## 📘 Learnings and Takeaways

### 🔹 Flush Is a Logical Snapshot, Not a Global Reset

Capturing write pointers at flush time is key to correctness.

---

### 🔹 Asymmetric FIFOs Require Structured Storage

Row/column organization simplifies width conversion and control logic.

---

### 🔹 Allowing Writes During Flush Improves Throughput

Decoupling flush and write paths avoids unnecessary stalls.

---

### 🔹 Edge Conditions Matter Most

Partial rows, padding rules, and boundary timing are the hardest parts and the most critical.

---

## 🚀 Summary

This FIFO Flush design provides a **robust and high-performance solution** for asymmetric-width buffering with flush capability. It carefully balances correctness, concurrency, and strict interface guarantees, making it suitable for real SoC datapath designs as well as advanced RTL interviews.


