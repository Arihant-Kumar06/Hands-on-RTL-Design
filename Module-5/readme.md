# Single-Cycle Fixed-Priority Arbiter (SystemVerilog)

## 1. Short Explanation of the Question

The problem asks us to design a **parameterized single cycle arbiter** that selects **one winner every clock cycle** from multiple requesting ports.

- Each port raises a request using a bit in `req_i`
- The arbiter must generate a **one hot grant (`gnt_o`)**
- A **fixed priority scheme** is used:
  - Port `0` has the highest priority
  - Priority decreases as the port index increases
- If multiple ports request simultaneously, the **lowest numbered port wins**
- The decision must be made **within the same cycle** (no state or memory)

---

## 2. Intuition Behind the Question

Think of this like a strict rule:

> "Among all ports asking for access, always pick the first one starting from port 0."

There is:
- No fairness requirement
- No memory of past grants
- No waiting

Every cycle is independent.

The core challenge is:
> **How do we block lower priority requests when a higher priority request exists?**

---

## 3. Design Approach (Prefix-OR Based Arbiter)

The design uses **pure combinational logic** and works in two steps:

### Step 1: Track higher priority requests

We create an internal signal called `priority_req`.

For each bit `i`:
- `priority_req[i] = 1` means **some higher priority port (0 to i-1) is requesting**
- `priority_req[0]` is always `0` because port 0 has no higher priority ports

This is implemented using a **prefix OR chain**.

### Step 2: Generate the grant

A port is granted **only if**:
- It is requesting (`req_i[i] == 1`)
- No higher priority port is requesting (`priority_req[i] == 0`)

This is done using:
```
gnt_o = req_i & ~priority_req;
```

This guarantees:
- Only one bit in `gnt_o` can be `1`
- The highest priority request always wins

---

## 4. For-Loop + Break Approach (Short Description)

Another common way to write the arbiter is using a `for` loop with a `break`:

```systemverilog
always_comb begin
    gnt_o = '0;
    for (int i = 0; i < N; i++) begin
        if (req_i[i]) begin
            gnt_o[i] = 1'b1;
            break;
        end
    end
end
```

### What this does
- Scans from LSB to MSB
- Grants the first request found
- Stops scanning using `break`

This style is:
- Easy to read
- Very intuitive
- Common in interviews and learning environments

However, it describes **behavior**, not explicit hardware structure.

---

## 5. Why the Prefix-OR Approach Is Better Than For-Loop + Break

This is the key insight.

### Core difference (simple terms)

- **For-loop + break**:  
  > "Here is the rule. Tool, you figure out the hardware."

- **Prefix-OR approach**:  
  > "Here is exactly how higher priority requests block lower ones."

### Why prefix-OR is better

1. **Explicit hardware**
   - The priority logic is visible as OR gates
   - Blocking is clearly expressed

2. **Predictable timing**
   - Logic depth is obvious
   - Easier to reason about critical paths

3. **Better debuggability**
   - `priority_req` clearly shows *why* a port lost
   - Much easier to debug in waveforms

4. **Better for large designs**
   - Scales cleanly to large `N`
   - Preferred in production RTL and ASIC flows

The for-loop relies on the tool to infer priority logic, while the prefix-OR method **directly encodes the priority structure**.

---

## 6. Takeaways, Learnings, and Insights

- A fixed-priority arbiter is fundamentally a **priority encoder**
- Arbitration can be done with **pure combinational logic**
- There is no real concept of "loop" or "break" in hardware
- Structural clarity matters more than coding convenience in real RTL
- Prefix-OR logic clearly shows:
  - Who blocks whom
  - Why a specific port won or lost
- For-loop + break is fine for:
  - Learning
  - Interviews
  - Small blocks
- Prefix-OR is preferred for:
  - Production RTL
  - Large SoCs
  - Debugging and verification

---

## 7. One-Line Summary

> A prefix-OR arbiter explicitly encodes priority blocking in hardware, making the design more predictable, debuggable, and scalable than a behavioral for-loop with break.
