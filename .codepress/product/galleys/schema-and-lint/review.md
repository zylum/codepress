# Review: schema-and-lint

## Signals
- Template guidance text counted as section content, so `shape_complete` passed on an untouched scaffold. A gate that cannot say no is theatre. Fixed by moving guidance into HTML comments and making both AC parsers (bash awk, Python) comment-aware.
- Two implementations of the AC grammar (bash `extract_acs`, Python `parse_acs`) will diverge unless something compares them; `tests/test_ac_parity.sh` runs both over every artefact in the repo.
- An inline `# comment` on a template's `status:` line broke every older grep|sed reader. Template status lines stay bare; vocabulary goes on a comment line above.
- The 0.1.0-vs-0.2.0 marker mismatch had a mechanical cause: `codepress upgrade` overwrote project-owned `codepress.md` while a legacy `config.md` kept its old marker. Fixed at the source: upgrade only moves the marker.
- A default tool name leaked into `lib/lint.py`; the self-lint test (no product names in lib/schema) caught it and the default is now passed in from the CLI.
- `legacy: true` would be a loophole on live galleys; it is honoured only on terminal ones.

## Evidence
- `bash tests/run_tests.sh` — 543 passed, 0 failed on branch `slug-01-schema-and-lint`.
- `codepress lint --base none` on this repo — PASS; its remaining warning is the older enforced-acceptance galley's undrained status (see drift D006).
- `bash tests/test_walkthrough.sh` — init → shape → split → approve → build → verify → learn → done on a fresh project, lint clean at every step.

## Verdict
<!-- Written by the VERIFIER engine only — never the builder.
AC1: pass — <evidence>
verified-by: <engine — must differ from engines.build>
verified-on: <YYYY-MM-DD>
-->
