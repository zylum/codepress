---
record: signal
id: sig-YYYY-MM-DD-a
created: YYYY-MM-DD
galley:                     # the galley it came from
slug:                       # optional
failure_class:              # kebab-case, countable: silent-failure, stale-state, format-drift, ...
caught_by:                  # lint | test | typecheck | review | verifier | human | monitoring | none
should_have_been_caught_by: # the gate that ought to have caught it: a gate name, none, or unknown
action: pattern             # new-gate | pattern | accepted-risk
status: open                # open | resolved | dropped
resolved_by:                # required when resolved: the gate, pattern or commit
risk_note:                  # required when action is accepted-risk
---

# Signal: [one-line observation]

What happened, in plain words. What would have prevented it.
