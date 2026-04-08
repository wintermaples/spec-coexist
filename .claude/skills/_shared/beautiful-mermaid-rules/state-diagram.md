# Rules for Creating Beautiful Mermaid State Diagrams

This document summarizes the principles for writing Mermaid **State Diagrams (`stateDiagram-v2`)** in design documentation (requirements, basic designs, etc.) so they stay "readable" and "robust as they scale."

---

## 1. Overview and Purpose

A State Diagram expresses the **lifecycle** and **event-driven behavior** of a target (entity, screen, job, session, etc.). It corresponds to UML state-machine diagrams.

Main uses:

- State transitions of business entities (orders, applications, contracts, etc.)
- Screen / wizard navigation
- Status management of asynchronous jobs and batch processes
- Protocol / connection session state management
- Visualizing error handling including exceptions and retries

**When not to use:**

- Plain processing flows → use Flowchart
- Message exchanges between a subject and counterpart → use Sequence Diagram
- Data-structure relationships → use ER / Class Diagram

> Principle: Use a State Diagram only when "there is a single subject," "it has state," and "it transitions on events."

---

## 2. Handling `[*]` (Start / End)

`[*]` is a pseudo state representing both initial and final. Direction of the arrow determines meaning.

- `[*] --> Draft` … Start
- `Closed --> [*]` … End

**Rules:**

1. **Always include a start `[*]`** for every top-level diagram (avoid implicit starts).
2. When there are multiple endings (normal termination / cancellation / failure), don't collapse into a single `[*]`. Either split them or route through explicit final states first.
3. A composite state can have its own internal `[*]` (indicating the initial substate when entering).

---

## 3. State Naming Conventions

A state expresses "the condition the subject is in," so use **noun or adjective phrases**. Never use verb phrases (process names).

| Good | Bad | Reason |
|---|---|---|
| `AwaitingReview` | `Review` | Verbs are transitions / actions |
| `Shipping` | `Ship processing` | "Processing" is a work name, ambiguous |
| `Paid` | `Payment completion processing` | State is a resulting condition |
| `Draft` | `Edit screen` | Don't confuse a screen name with state |

**Additional rules:**

- Keep granularity consistent within a diagram (avoid mixing "Application" with "Credit-check suspension substate").
- Don't mix English and other languages. Pick one style.
- Avoid spaces and symbols in IDs; alias display names with `state "Draft" as Draft`.

```
stateDiagram-v2
  state "Draft" as Draft
  state "AwaitingReview" as PendingReview
  Draft --> PendingReview: Submit
```

---

## 4. Transition Labels

Use the UML standard format **`event [guard] / action`**. In Mermaid, put this string after the colon `:`.

```
Draft --> PendingReview: Submit [inputs complete] / send notification
```

**Rules:**

1. Don't pack multiple events into one transition. Split into separate arrows for different events.
2. Guard conditions go in square brackets `[ ]`, kept short. Use `note` for long conditions.
3. Actions are limited to side effects (external notifications, logs, state updates). Don't write internal procedure steps.
4. For label-less transitions (automatic), always explain with a note.

---

## 5. Composite States and Nesting Depth

Group related states with composite states.

```
stateDiagram-v2
  [*] --> Accepting
  state Accepting {
    [*] --> Entering
    Entering --> Confirming: Next
    Confirming --> Entering: Back
  }
  Accepting --> Completed: Confirm
  Completed --> [*]
```

**Nesting-depth limit: 2 levels (3 maximum).**
If you want to go deeper, **extract the inner composite into a separate diagram (sub-machine)**. Deep nesting severely hurts readability and rendering quality.

---

## 6. Concurrent Regions

When one subject has multiple independent simultaneous states, divide a composite state with `--`.

```
stateDiagram-v2
  state InCall {
    [*] --> AudioOn
    AudioOn --> AudioOff: Mute
    AudioOff --> AudioOn: Unmute
    --
    [*] --> VideoOn
    VideoOn --> VideoOff: CameraOff
    VideoOff --> VideoOn: CameraOn
  }
```

**Rules:**

- Keep concurrent regions to **2–3**. Split into separate diagrams beyond that.
- Make dependencies between regions (where one region affects another) explicit with **notes**. Do not cross lines on the diagram.

---

## 7. choice / fork / join Nodes

- `<<choice>>`: Guarded branching (diamond)
- `<<fork>>`: 1 → many parallel start
- `<<join>>`: many → 1 synchronization

```
stateDiagram-v2
  state if_state <<choice>>
  Accept --> if_state: Receive application
  if_state --> AutoApproved: [amount < 10k]
  if_state --> ManualReview: [amount >= 10k]
```

```
stateDiagram-v2
  state fork_state <<fork>>
  state join_state <<join>>
  Start --> fork_state
  fork_state --> ReserveStock
  fork_state --> CheckCredit
  ReserveStock --> join_state
  CheckCredit --> join_state
  join_state --> PrepareShipment
```

A `choice` should have **2–3 branches** at most. With 4+, reconsider state design.

---

## 8. `direction TB` / `LR`

```
stateDiagram-v2
  direction LR
  ...
```

- **LR (left → right)**: Procedural, time-ordered lifecycles (application → review → approval → done)
- **TB (top → bottom)**: Hierarchical / classificational, or diagrams with many concurrent regions
- Composite states can set their own `direction`, independent of the outside
- Keep one style per diagram. Only flip internally when it has meaning.

---

## 9. Using `note`

```
stateDiagram-v2
  InReview --> Approved: Approve
  note right of InReview
    SLA: within 2 business days from acceptance
    Owner: Credit team
  end note
```

**Uses:**

- Annotating long guard conditions / business rules
- Stating SLAs, timeout values, involved parties
- Describing external-system integrations

Limit notes to **one per state**. Move the rest to body documentation.

---

## 10. Handling Scale

As state count grows, state diagrams quickly become unreadable. Control it with:

1. **Hierarchy**: Group related states in composite states. Don't start flat.
2. **Submachine split**: Move composite contents into a separate diagram; in the parent, treat it as a black box (link in the heading).
3. **Split by viewpoint**: Separate "happy path only," "error / retry," and "concurrent resources" diagrams.
4. **State-count guideline**: **Within 15 states per diagram**. Split beyond that.
5. **Transition-count guideline**: **Within 30 transitions per diagram**.

---

## 11. Anti-patterns

### 11.1 State explosion

Turning every attribute combination into its own state.

**Fix**: Put orthogonal attributes into **concurrent regions**, or treat them as data and use guards.

### 11.2 Many crossing transitions

Writing "can cancel from anywhere" as separate arrows from every state.

**Fix**: Create a common ancestor composite state and aggregate into one transition from the composite → Cancelled (UML "transition from composite state").

### 11.3 Overlapping state meanings

Coexisting states like `OnHold`, `Suspended`, and `Waiting`.

**Fix**: Make a glossary and normalize to "one meaning, one state name."

### 11.4 Verb-named states

Using state names like `Register` or `Submit`. State is a condition, not an action.

### 11.5 Missing termination

No final `[*]`, so it's unclear when the subject finishes.

---

## 12. Good / Bad Examples

### 12.1 Bad: flat, verbs mixed, no start/end

```
stateDiagram-v2
  CreateDraft --> Submit
  Submit --> Review
  Review --> Approve
  Review --> SendBack
  SendBack --> CreateDraft
  Approve --> Complete
```

Problems: Verb states, no `[*]`, no guards or reasons for send-back.

### 12.2 Good: Noun phrases, start/end, guards and actions

```
stateDiagram-v2
  direction LR
  [*] --> Draft
  Draft --> AwaitingReview: Submit [required fields filled]
  AwaitingReview --> Approved: Approve / send notification
  AwaitingReview --> SentBack: Send back [findings exist] / save comments
  SentBack --> Draft: Start revising
  Approved --> [*]
```

### 12.3 Bad: nesting too deep

```
stateDiagram-v2
  state A {
    state B {
      state C {
        state D {
          [*] --> E
        }
      }
    }
  }
```

### 12.4 Good: limited to 2 levels, deep parts split out

```
stateDiagram-v2
  [*] --> Accepting
  state Accepting {
    [*] --> Entering
    Entering --> Confirming
    Confirming --> Entering: Back
  }
  Accepting --> Review: Confirm
  Review --> [*]
  note right of Review
    See "Review submachine diagram"
  end note
```

### 12.5 Bad: Arrows from all states to Cancelled

```
stateDiagram-v2
  Draft --> Cancelled: Cancel
  AwaitingReview --> Cancelled: Cancel
  SentBack --> Cancelled: Cancel
  Approved --> Cancelled: Cancel
```

### 12.6 Good: Consolidate cancellation with a composite

```
stateDiagram-v2
  [*] --> InProgress
  state InProgress {
    [*] --> Draft
    Draft --> AwaitingReview: Submit
    AwaitingReview --> SentBack: Send back
    SentBack --> Draft: Revise
    AwaitingReview --> Approved: Approve
  }
  InProgress --> Cancelled: Cancel [within cancellable window]
  Approved --> [*]
  Cancelled --> [*]
```

### 12.7 Good: Using concurrent regions

```
stateDiagram-v2
  [*] --> InMeeting
  state InMeeting {
    [*] --> MicOn
    MicOn --> MicOff: Mute
    MicOff --> MicOn: Unmute
    --
    [*] --> CameraOn
    CameraOn --> CameraOff: Stop
    CameraOff --> CameraOn: Start
  }
  InMeeting --> [*]: Leave
```

### 12.8 Good: Conditional branching with choice

```
stateDiagram-v2
  state AmountCheck <<choice>>
  [*] --> ReceiveApplication
  ReceiveApplication --> AmountCheck
  AmountCheck --> AutoApproved: [amount < 10000]
  AmountCheck --> ManualReview: [amount >= 10000]
  AutoApproved --> [*]
  ManualReview --> [*]
```

---

## 13. Checklist

At review time, confirm the following.

- [ ] Are start `[*]` and end `[*]` explicit?
- [ ] Are state names noun phrases with consistent granularity?
- [ ] Do transition labels follow `event [guard] / action`?
- [ ] Is nesting within 2 levels?
- [ ] 15 or fewer states and 30 or fewer transitions?
- [ ] 3 or fewer concurrent regions?
- [ ] 3 or fewer choice branches?
- [ ] No redundant states with overlapping meaning?
- [ ] Are shared transitions (e.g., cancel) consolidated via a composite state?
- [ ] Is `direction` aligned with the diagram's intent (LR=time-ordered / TB=hierarchy)?
- [ ] Are notes limited to annotations and not overused?
