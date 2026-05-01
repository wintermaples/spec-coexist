# Hypothesis Template

Every hypothesis produced in step 3 of `exploring-problem-space` **MUST** match this shape:

```
H{n}: The real problem is {X}, and solving it will cause {observable outcome Y}.
Falsifier: If we {experiment}, and observe {counter-outcome}, this hypothesis is wrong.
Cost: {time/effort to run the falsifier}
```

## Rules

- **X** must be a *problem*, not a *solution*. Example: "Users cannot find the export button" is a problem; "add a bigger export button" is a solution.
- **Y** must be observable without implementing the solution. Leading indicators (support-ticket count, funnel drop-off, interview quotes) are acceptable; "revenue goes up" alone is not — too lagging.
- **Falsifier** must be *cheaper* than building the solution. A falsifier that costs as much as the feature is not a falsifier.
- A hypothesis without a falsifier **MUST** be deleted, not kept as "intuition".

## Anti-patterns

- Restatements of the user's wish with no new structure.
- Falsifiers of the form "ship it and see" — that is not falsification, it is gambling.
- Bundled claims ("users want X *and* Y *and* Z"). Split them into separate hypotheses.

## Example

```
H1: The real problem is that new users abandon onboarding at step 3 because they do not understand what a "workspace" means, and fixing the label will cause step-3 drop-off to fall below 20%.
Falsifier: Run a 5-user moderated test with the current label; if ≥4 understand it, this hypothesis is wrong.
Cost: half a day of user research.
```
