# Implementation Plan Template

The plan the agent presents to the user **MUST** contain all five sections below. Do not omit any section even if it seems short.

## Required Sections

### 1. Goal
One paragraph tied directly to the requirements document. Quote or reference the specific requirement(s) being addressed.

### 2. Affected Files / Modules
Concrete file paths or module names. "Various files" is not acceptable — be specific.

### 3. Step-by-Step Changes
Each step **MUST** be small enough to be independently reviewable. Batching unrelated changes into one step is not permitted.

### 4. Test Strategy
What tests will be added or modified, what existing tests are relevant, and how the agent will confirm the implementation is correct. "Run the test suite" alone is not a test strategy — name the specific test scenarios.

### 5. Open Questions / Risks
Anything still unclear about the requirements or design, any technical risk, any dependency that could block a step.

## Approval Rules

- Present the complete plan before writing any code.
- If the user pushes back, revise and re-present the plan in full.
- "Go ahead", "looks good", "approved", or equivalent unambiguous phrasing counts as approval.
- Do **NOT** interpret silence or a clarifying question as approval.
