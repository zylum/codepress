# Skill: Update Domain

Update Knowledge to reflect new concepts, decisions, or state changes.

---

## When to use
- After a Galley introduces a new concept
- After an architectural decision is made
- When system capabilities meaningfully change
- Before starting a new Galley in an unfamiliar area

---

## Steps

### 1. Identify what changed

- **New concept** — a domain entity or idea that didn't exist before
- **New term** — a word or acronym that needs defining
- **Decision** — a significant architectural or product choice
- **State change** — a new capability, limitation, or deprecation

### 2. Update the right file

| What changed | Where to update |
|---|---|
| New concept | `knowledge/concepts.md` |
| New term | `knowledge/glossary.md` |
| Decision | `knowledge/decisions/{date}-{name}.md` |
| State change | `knowledge/current-state.md` |

### 3. Write for the next reader

- Be specific enough that someone new to the project understands
- Reference files, line numbers, or commits where applicable
- Do not write essays — a short entry is better than none

---

## Principle

Knowledge is the shared understanding of the product.
It answers: *what does this system do and how does it work?*
Every update makes the next delivery faster and better.
