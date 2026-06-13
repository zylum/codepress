# Skill: Signal

Quick-capture an observation mid-session without running a full review.

---

## Steps

1. Identify the target file:
   - If a galley is active, use `product/galleys/{id}/review.md`
   - If no active galley, use `knowledge/signals/scratch.md` (create if absent)

2. Append under the `## Signals` section:
   ```
   - YYYY-MM-DD: <observation>
   ```
   Use today's date. One bullet per call. Keep the observation to one sentence.

3. No other changes. Do not open the review workflow. Do not restructure the file.

---

**Invoke:** `/signal <observation>` — or pass the text directly when calling this skill.
