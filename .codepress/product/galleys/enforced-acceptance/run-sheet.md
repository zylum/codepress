# Run sheet — enforced-acceptance

Strictly sequential — each slug is the next one's dependency:
01-acceptance-binding-format → 02-codepress-check-and-gated-move → 03-verifier-verdict-gate.

| # | Slug | Autonomy | Stop condition |
|---|------|----------|----------------|
| 1 | 01-acceptance-binding-format | continuous | if the one-line grammar can't express a real AC from an existing galley, stop — adjust the grammar, don't force the AC |
| 2 | 02-codepress-check-and-gated-move | confirm | if gating requires restructuring the CLI beyond `cmd_galley_move` + one new subcommand, stop and flag |
| 3 | 03-verifier-verdict-gate | confirm | if engine identity can't be established from codepress.md config, stop — do not invent an auth mechanism |

Gate: `bash tests/run_tests.sh` green before every commit.

Dogfood clause: this galley's own acceptance criteria are written in the slug-01
format. Once slug 02 lands, `codepress check enforced-acceptance` must run against
this very galley — it is fixture, spec, and first customer. Its move to `done`
must itself pass the slug-03 verdict gate.

Builder note (operating rules apply): no infra, no `[x]` on manual lines, Signals
before every commit, status goes to `review` — never `done` — when you finish.
