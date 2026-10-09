---
record: signal
id: sig-2026-10-09-a
created: 2026-10-09
galley: schema-and-lint
failure_class: generated-artifact-pollution
caught_by: verifier
should_have_been_caught_by: test
action: new-gate
status: resolved
resolved_by: "codepress runs lint with python3 -B; tests/test_lint.sh asserts no __pycache__ appears; .gitignore covers it"
---

# Signal: running lint left compiled bytecode inside a project's .codepress/system/lib

The verifier's fresh run failed AC9: a `__pycache__` directory created by running lint tripped the self-lint grep. The test was the symptom; the cause was that lint wrote bytecode into the user's project. Fixed at the source, not by excluding the directory.
