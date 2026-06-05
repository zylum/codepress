# CodePress Config

> Populated by `skills/bootstrap.md`. Edit freely after that.

---

## CodePress version
codepress-version: 0.1.0
codepress-source: https://github.com/zylum/codepress

---

## Project
name: 
description: 
garner-project:     # path relative to garner silos/ e.g. marv/projects/loom

---

## Release Theme
Each release is named after _____.
Use the theme name as the release codename when creating a new release.

Pool:
- 
- 
- 

---

## Working Style

### Pace
<!-- fast | balanced | careful -->
pace: balanced

| Value | Meaning |
|---|---|
| `fast` | Move quickly, iterate. Minimal checkpoints. Default autonomy: continuous. |
| `balanced` | Review at Galley boundaries. Human approves shape before delivery starts. |
| `careful` | Frequent checkpoints. Human reviews each Galley stage. Suits regulated or production-critical work. |

### Default Task autonomy
<!-- continuous | confirm | stop — overrides pace for individual Tasks -->
default-autonomy: continuous

### Human approval gates
<!-- Which transitions require explicit human sign-off? -->
- [ ] Galley: shaping → approved
- [ ] Galley: delivering → review
- [ ] Galley: review → done

### Testing expectations
<!-- What does "done" require? -->
- 

### PR policy
<!-- e.g. PR required before merge, auto-merge on green CI, etc. -->
- 

---

## Team
<!-- solo | small-team | team -->
team-size: solo

Roles:
<!-- List roles active on this project, e.g. Shaper, Builder, Reviewer -->
- 

---

## Conventions
<!-- Project-specific naming, commit, or workflow conventions -->
- 

---

## Example (delete when filled in)

```
## Project
name: Loom
description: MCP and access layer connecting AI systems to Garner.
garner-project: marv/projects/loom

## Release Theme
Each release is named after an iconic 80s movie.
Pool: Back to the Future, Ghostbusters, Top Gun, Ferris Bueller's Day Off,
The Terminator, RoboCop, Beetlejuice, Die Hard, Aliens, Blade Runner

## Working Style
pace: balanced
default-autonomy: confirm

Human approval gates:
- [x] Galley: shaping → approved
- [ ] Galley: delivering → review
- [x] Galley: review → done

Testing expectations:
- Unit tests required for all business logic
- E2E tests for critical user journeys

PR policy:
- PR required before merge to main
- At least one human review for Galleys touching auth or billing

## Team
team-size: small-team
Roles:
- Shaper (human)
- Builder (AI)
- Reviewer (AI + human sign-off)
```
