# Events to APB Converter

## 📌 Problem Description (Short)
Design a hardware block that converts incoming event signals into compliant **AMBA APB write transactions**. The module accepts three mutually exclusive event inputs and, upon detecting events, generates APB write transactions to fixed addresses. Each transaction writes the **count of events seen since the last write** for that event.

---

## 💡 Design Intuition

At a high level, this problem is about **bridging two timing domains**:
- An **event-driven interface** (events can arrive any cycle)
- A **transaction-based APB bus** (strict protocol with phases)

Key ideas behind the design:

- Use a **finite state machine (FSM)** to strictly follow the APB protocol (IDLE → SETUP → ACCESS)
- **Accumulate events** using counters while waiting for the APB bus to become available
- Convert multiple fast events into a **single APB write** using event counts
- Ensure **no back-to-back transactions** by returning to IDLE after each ACCESS phase
- Use registered address and data to keep signals **stable across APB phases**

The fairness guarantee allows a **simple fixed-priority selection** of events without starvation concerns.

---

## 🛠️ Design Process

1. **APB FSM Design**
   - Implemented a 3-state FSM: `IDLE`, `SETUP`, `ACCESS`
   - Ensures full compliance with AMBA APB timing

2. **Event Detection & Prioritization**
   - Detects new events or pending event counts
   - Selects one event address based on fixed priority (A > B > C)

3. **Event Counting Mechanism**
   - Separate counters for each event
   - Counters increment on incoming events
   - Counter resets when its value is written to APB

4. **APB Signal Generation**
   - `PSEL` asserted in SETUP & ACCESS
   - `PENABLE` asserted only in ACCESS
   - `PWRITE` permanently tied to write

5. **Write Data Handling**
   - Write data is latched **before SETUP**
   - Ensures data stability during ACCESS

6. **Protocol Constraints Handling**
   - No back-to-back transfers enforced by FSM
   - Slave wait handled via `PREADY`

---

## 🎓 Learnings & Takeaways

- Clear understanding of **AMBA APB protocol timing**
- Importance of **FSM-based bus interface design**
- How to safely convert **event-based signals into bus transactions**
- Using counters to **batch multiple events** efficiently
- Handling wait states and bus handshakes cleanly
- Writing synthesizable, readable, and protocol-compliant RTL

This problem closely mirrors **real SoC peripheral design** patterns.

---

## ❓ Commonly Asked Interview Questions

### 1. Why do we need a SETUP and ACCESS phase in APB?
APB separates address/control setup from data transfer to keep the protocol simple and low-power, allowing peripherals to sample signals cleanly.

### 2. Why is write data registered instead of being combinational?
APB requires data to remain stable during the ACCESS phase. Registering data ensures timing correctness even if internal logic changes.

### 3. How does the design avoid back-to-back APB transactions?
After completing ACCESS, the FSM always returns to IDLE, enforcing a mandatory gap cycle.

### 4. What happens if multiple events occur while APB is busy?
They are accumulated using per-event counters and sent as a single write when the bus becomes free.

### 5. Why are separate counters used for each event?
Each event maps to a unique address and requires an independent count of occurrences.

### 6. Could this design support APB reads?
Yes, with additional logic for `PWRITE=0`, `PRDATA` handling, and read response timing.

### 7. Why is fixed priority safe in this design?
The problem guarantees fairness at the input, ensuring no event can starve even with fixed priority.

### 8. How would you extend this design for more events?
Use parameterized event arrays, counters, and a priority encoder or round-robin arbiter.

---

## ✅ Summary
This module demonstrates a clean, protocol-correct approach to converting asynchronous events into APB transactions—a pattern frequently used in real-world SoC peripheral and bus interface design.

---

📂 *Ideal for showcasing FSM design, bus protocols, and RTL design skills on GitHub.*

