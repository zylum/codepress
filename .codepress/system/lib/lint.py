#!/usr/bin/env python3
"""codepress lint — the single enforcement point for the CodePress lifecycle.

Reads the lifecycle and field schemas in ../schema/ and checks a project's
galleys, slugs and signals against them. Static and fast: it never runs the
project's tests, so it is safe in a git hook and in CI. (`codepress check`
runs the dynamic gates.)

    lint.py lint [--root DIR] [--base REF|none] [--strict] [--json] [--galley NAME]...
    lint.py status-json [--root DIR] [--stalled-after DAYS]
    lint.py canon KIND STATUS          canonical status for a (possibly retired) value
    lint.py aliases KIND               legacy=canonical lines
    lint.py requires FROM TO           requirements of a galley transition
    lint.py gate GALLEY FROM TO        evaluate the static requirements of a move
    lint.py acs FILE                   id|kind|payload|ticked lines (parity with the CLI)
    lint.py mapping                    the legacy status mapping as a markdown table
    lint.py check-schema               self-consistency of the schema files

Exit: 0 clean (warnings allowed unless --strict), 1 findings at error level,
2 usage / internal error.

Standard library only; Python 3.8+.
"""

import argparse
import datetime
import json
import os
import re
import subprocess
import sys

LIB_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, LIB_DIR)
import miniyaml  # noqa: E402

SCHEMA_DIR = os.path.join(os.path.dirname(LIB_DIR), "schema")

ERROR = "error"
WARN = "warn"
INFO = "info"  # shown only with --verbose; never fails (legacy noise)

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+([-+][0-9A-Za-z.-]+)?$")


# ─── Findings ────────────────────────────────────────────────────────────────


class Finding(object):
    def __init__(self, code, severity, path, message, fix=None):
        self.code = code
        self.severity = severity
        self.path = path
        self.message = message
        self.fix = fix

    def as_dict(self):
        d = {
            "code": self.code,
            "severity": self.severity,
            "path": self.path,
            "message": self.message,
        }
        if self.fix:
            d["fix"] = self.fix
        return d


# ─── Schema ──────────────────────────────────────────────────────────────────


class Schema(object):
    """The lifecycle + field schemas, loaded from the schema directory."""

    def __init__(self, schema_dir=SCHEMA_DIR):
        self.dir = schema_dir
        self.lifecycle = miniyaml.load(os.path.join(schema_dir, "lifecycle.yaml"))
        self.galley_fields = miniyaml.load(os.path.join(schema_dir, "galley.schema.yaml"))
        self.slug_fields = miniyaml.load(os.path.join(schema_dir, "slug.schema.yaml"))
        self.signal_fields = miniyaml.load(os.path.join(schema_dir, "signal.schema.yaml"))
        self.gates = self.lifecycle.get("gates") or {}
        wp = (self.lifecycle.get("waiver") or {}).get("pattern")
        self.waiver_re = re.compile(wp) if wp else None

    # -- statuses ------------------------------------------------------------

    def section(self, kind):
        return self.lifecycle[kind]

    def statuses(self, kind):
        return list((self.section(kind).get("statuses") or {}).keys())

    def is_terminal(self, kind, status):
        info = (self.section(kind).get("statuses") or {}).get(status) or {}
        return bool(info.get("terminal"))

    def legacy_map(self, kind):
        return (self.lifecycle.get("legacy") or {}).get(kind) or {}

    def canon(self, kind, status):
        """Return (canonical_status | None, legacy_entry | None).

        A canonical value returns (value, None). A retired value returns its
        mapping. An unknown value returns (None, None).
        """
        if status in self.statuses(kind):
            return status, None
        entry = self.legacy_map(kind).get(status)
        if entry:
            return entry.get("to"), entry
        return None, None

    # -- transitions and gates ----------------------------------------------

    def transitions(self, kind):
        return self.section(kind).get("transitions") or {}

    def edge(self, kind, a, b):
        return self.transitions(kind).get("%s->%s" % (a, b))

    def mainline(self):
        return self.section("galley").get("mainline") or []

    def state_requires(self, status):
        """Requirements that must hold for a galley sitting at `status`."""
        main = self.mainline()
        reqs = []
        if status in main:
            for i in range(1, main.index(status) + 1):
                e = self.edge("galley", main[i - 1], main[i]) or {}
                for r in e.get("requires") or []:
                    if r not in reqs:
                        reqs.append(r)
            return reqs
        # side statuses (killed, superseded): the requirements of any edge into
        # them — check-schema asserts every edge into a status agrees.
        for key, e in self.transitions("galley").items():
            if key.split("->")[1] == status:
                for r in (e or {}).get("requires") or []:
                    if r not in reqs:
                        reqs.append(r)
                break
        return reqs

    def gate_kind(self, gate):
        return (self.gates.get(gate) or {}).get("kind", "static")

    def gate_fix(self, gate):
        return (self.gates.get(gate) or {}).get("fix")

    def gate_actor(self, gate):
        return (self.gates.get(gate) or {}).get("actor", "agent")

    # -- self-consistency ------------------------------------------------------

    def check(self):
        """Return a list of problems with the schema files themselves."""
        problems = []
        for kind in ("galley", "slug"):
            sec = self.section(kind)
            sts = self.statuses(kind)
            if sec.get("initial") not in sts:
                problems.append("%s.initial %r is not a %s status" % (kind, sec.get("initial"), kind))
            for key, e in self.transitions(kind).items():
                if "->" not in key:
                    problems.append("%s transition %r is not 'a->b'" % (kind, key))
                    continue
                a, b = key.split("->")
                for s in (a, b):
                    if s not in sts:
                        problems.append("%s transition %s names unknown status %r" % (kind, key, s))
                if self.is_terminal(kind, a):
                    if not (kind == "slug" and a in ("closed", "dropped")):
                        problems.append("%s transition %s leaves terminal status %r" % (kind, key, a))
                for r in (e or {}).get("requires") or []:
                    if r not in self.gates:
                        problems.append("%s transition %s requires unknown gate %r" % (kind, key, r))
            for mapping_from, entry in self.legacy_map(kind).items():
                if mapping_from in sts:
                    problems.append("legacy %s status %r is also canonical" % (kind, mapping_from))
                if (entry or {}).get("to") not in sts:
                    problems.append("legacy %s %r maps to unknown status %r" % (kind, mapping_from, (entry or {}).get("to")))
        main = self.mainline()
        for i in range(1, len(main)):
            if not self.edge("galley", main[i - 1], main[i]):
                problems.append("mainline step %s->%s has no transition" % (main[i - 1], main[i]))
        # every edge into a side status must agree on requirements
        into = {}
        for key, e in self.transitions("galley").items():
            if "->" not in key:
                continue
            b = key.split("->")[1]
            if b in main:
                continue
            into.setdefault(b, set()).add(tuple((e or {}).get("requires") or []))
        for b, variants in into.items():
            if len(variants) > 1:
                problems.append("edges into %r disagree on requirements" % b)
        for gname, g in self.gates.items():
            if (g or {}).get("kind") not in ("static", "dynamic"):
                problems.append("gate %r has no kind (static|dynamic)" % gname)
        for fname, spec in (self.galley_fields.get("fields") or {}).items():
            if (spec or {}).get("type") == "enum" and not ((spec or {}).get("values") or (spec or {}).get("values_from")):
                problems.append("galley field %r is an enum without values" % fname)
        return problems


# ─── Markdown helpers (mirror the CLI's awk) ─────────────────────────────────


def strip_html_comments(text):
    return re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)


def section_text(text, prefix):
    """Body of the first '## <prefix>...' section, up to the next '## '."""
    out, inside = [], False
    for line in text.split("\n"):
        if line.startswith("## " + prefix):
            inside = True
            continue
        if inside and line.startswith("## "):
            break
        if inside:
            out.append(line)
    return "\n".join(out) if inside else None


def has_content(text):
    return text is not None and bool(strip_html_comments(text).strip())


def parse_acs(text):
    """Acceptance criteria as dicts. Mirrors the CLI's extract_acs (awk)."""
    acs = []
    inside = False
    in_comment = False
    for line in text.split("\n"):
        # Lines inside an HTML comment block are not criteria. A line that opens a
        # comment without closing it starts the block; a line holding `-->` ends it.
        if in_comment:
            if "-->" in line:
                in_comment = False
            continue
        if "<!--" in line and "-->" not in line.split("<!--", 1)[1]:
            in_comment = True
            continue
        if line.startswith("## Acceptance"):
            inside = True
            continue
        if inside and line.startswith("## "):
            inside = False
        if inside and re.match(r"^- \[[ xX]\] ", line):
            ticked = bool(re.match(r"^- \[[xX]\]", line))
            body = re.sub(r"^- \[[ xX]\][ \t]*", "", line).rstrip(" \t")
            ac_id, kind, payload = "", "legacy", body
            sep = body.find(" · ")
            if sep >= 0:
                ac_id = body[:sep]
            for marker, k in ((" · check: ", "check"), (" · manual: ", "manual"), (" · test: ", "test")):
                pos = body.find(marker)
                if pos >= 0:
                    kind, payload = k, body[pos + len(marker):]
                    break
            else:
                ac_id = ""
            acs.append({"id": ac_id, "kind": kind, "payload": payload, "ticked": ticked})
    return acs


def unticked_acs(acs):
    """Boxes that still need ticking: manual steps are attested by a human."""
    return [a for a in acs if not a["ticked"] and a["kind"] != "manual"]


def parse_plan_changes(text):
    """Entries of a plan-changes.md: [{date, title, plan, changed, why, text}], errors."""
    entries, errors = [], []
    text = strip_html_comments(text)
    head = re.compile(r"^##\s+(\d{4}-\d{2}-\d{2})\s*[—–-]\s*(.+?)\s*$")
    labels = {"plan said": "plan", "changed": "changed", "why": "why", "affects": "affects"}
    cur = None
    cur_label = None
    for line in text.split("\n"):
        m = head.match(line)
        if m:
            cur = {"date": m.group(1), "title": m.group(2), "plan": "", "changed": "", "why": "", "affects": "", "text": ""}
            entries.append(cur)
            cur_label = None
            continue
        if line.startswith("## "):
            if re.match(r"^##\s+\d", line):
                errors.append("malformed entry heading %r (want '## YYYY-MM-DD — title')" % line.strip())
            cur = None
            cur_label = None
            continue
        if cur is None:
            continue
        cur["text"] += line + "\n"
        lm = re.match(r"^[-*]\s+\**\s*([A-Za-z ]+?)\s*:\s*\**\s*(.*)$", line)
        if lm and lm.group(1).lower() in labels:
            cur_label = labels[lm.group(1).lower()]
            cur[cur_label] = lm.group(2).strip()
        elif cur_label and line.strip() and line.startswith((" ", "\t")):
            cur[cur_label] += " " + line.strip()
        elif line.strip() == "":
            pass
    for e in entries:
        missing = [lbl for lbl in ("plan", "changed", "why") if not e[lbl].strip()]
        if missing:
            names = {"plan": "Plan said", "changed": "Changed", "why": "Why"}
            errors.append("entry %s '%s' is missing: %s" % (e["date"], e["title"], ", ".join(names[m] for m in missing)))
    return entries, errors


# ─── Git ─────────────────────────────────────────────────────────────────────


class Git(object):
    def __init__(self, root):
        self.root = root
        self.ok = self._run(["rev-parse", "--is-inside-work-tree"])[0] == 0
        self._commits = None

    def _run(self, args):
        try:
            p = subprocess.run(
                ["git"] + args, cwd=self.root, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=60
            )
            return p.returncode, p.stdout.decode("utf-8", "replace")
        except (OSError, subprocess.TimeoutExpired):
            return 1, ""

    def has_ref(self, ref):
        return self.ok and self._run(["rev-parse", "--verify", "--quiet", ref + "^{commit}"])[0] == 0

    def show(self, ref, relpath):
        """Content of relpath (relative to root) at ref, or None."""
        if not self.ok:
            return None
        rc, out = self._run(["show", "%s:./%s" % (ref, relpath)])
        return out if rc == 0 else None

    def commits(self, limit=20000):
        """[{sha, date, subject, body, files}], newest first. Cached."""
        if self._commits is not None:
            return self._commits
        self._commits = []
        if not self.ok or not self.has_ref("HEAD"):
            return self._commits
        fmt = "%x1e%H%x1f%cI%x1f%s%x1f%b%x1f"
        rc, out = self._run(["log", "-n", str(limit), "--name-only", "--format=" + fmt])
        if rc != 0:
            return self._commits
        for rec in out.split("\x1e"):
            if not rec.strip():
                continue
            parts = rec.split("\x1f")
            if len(parts) < 5:
                continue
            files = [f for f in parts[4].split("\n") if f.strip()]
            self._commits.append(
                {"sha": parts[0].strip(), "date": parts[1], "subject": parts[2], "body": parts[3], "files": files}
            )
        return self._commits


# ─── Project model ───────────────────────────────────────────────────────────


class Slug(object):
    def __init__(self, galley, path):
        self.galley = galley
        self.path = path
        self.stem = os.path.splitext(os.path.basename(path))[0]
        self.error = None
        try:
            with open(path, encoding="utf-8") as fh:
                self.text = fh.read()
            self.fm, self.body = miniyaml.frontmatter(self.text)
        except (miniyaml.YamlError, OSError, UnicodeDecodeError) as exc:
            self.text, self.fm, self.body, self.error = "", {}, "", str(exc)
        self.id = str(self.fm.get("id") or self.stem)
        self.status = self.fm.get("status")
        self.acs = parse_acs(self.body)

    def names(self):
        """Names a commit may use for this slug."""
        out = {self.id, self.stem, re.sub(r"^\d+[-_]", "", self.stem)}
        return set(n for n in out if n)


class Galley(object):
    def __init__(self, project, dirpath):
        self.project = project
        self.dir = dirpath
        self.name = os.path.basename(dirpath)
        self.path = os.path.join(dirpath, "galley.md")
        self.error = None
        try:
            with open(self.path, encoding="utf-8") as fh:
                self.text = fh.read()
            self.fm, self.body = miniyaml.frontmatter(self.text)
        except (miniyaml.YamlError, OSError, UnicodeDecodeError) as exc:
            self.text, self.fm, self.body, self.error = "", {}, "", str(exc)
        self.id = str(self.fm.get("id") or self.name)
        self.status = self.fm.get("status")
        self.acs = parse_acs(self.body)
        self.slugs = []
        sdir = os.path.join(dirpath, "slugs")
        if os.path.isdir(sdir):
            for fn in sorted(os.listdir(sdir)):
                if fn.endswith(".md"):
                    self.slugs.append(Slug(self, os.path.join(sdir, fn)))
        self.review = self._read("review.md")
        self.learned = self._read("learned.md")
        self.plan_changes = self._read("plan-changes.md")

    def _read(self, fn):
        p = os.path.join(self.dir, fn)
        if not os.path.isfile(p):
            return None
        try:
            with open(p, encoding="utf-8") as fh:
                return fh.read()
        except (OSError, UnicodeDecodeError):
            return None

    def title(self):
        m = re.search(r"^# Galley:\s*(.+?)\s*$", self.body, flags=re.MULTILINE)
        return m.group(1) if m else self.name

    def rel(self, project, fn="galley.md"):
        return os.path.relpath(os.path.join(self.dir, fn), project.root)


class Project(object):
    def __init__(self, root, schema):
        self.root = os.path.abspath(root)
        self.schema = schema
        self.cp = os.path.join(self.root, ".codepress")
        self.galleys = []
        gdir = os.path.join(self.cp, "product", "galleys")
        if os.path.isdir(gdir):
            for name in sorted(os.listdir(gdir)):
                d = os.path.join(gdir, name)
                if name.startswith("_") or not os.path.isfile(os.path.join(d, "galley.md")):
                    continue
                self.galleys.append(Galley(self, d))
        self.git = Git(self.root)

    # -- config -------------------------------------------------------------------

    def config_path(self):
        for fn in ("codepress.md", "config.md"):
            p = os.path.join(self.cp, "system", fn)
            if os.path.isfile(p):
                return p
        return None

    def engine(self, stage):
        """engines.<stage> from codepress.md.

        When the block is missing the CLI's documented default applies; the CLI
        passes it in CODEPRESS_DEFAULT_ENGINE so there is one definition of it.
        Run standalone, an unset engine is "" — independence can then only be
        judged by the verdict naming *someone*.
        """
        p = self.config_path()
        if p:
            inside = False
            try:
                with open(p, encoding="utf-8") as fh:
                    for line in fh:
                        if re.match(r"^engines:\s*$", line):
                            inside = True
                            continue
                        if inside and re.match(r"^\S", line):
                            inside = False
                        if inside:
                            m = re.match(r"^\s{2}%s:\s*(.*)$" % re.escape(stage), line)
                            if m:
                                val = re.sub(r"\s*#.*$", "", m.group(1)).strip()
                                if val:
                                    return val
            except OSError:
                pass
        return os.environ.get("CODEPRESS_DEFAULT_ENGINE", "")

    def galley_by_name(self, name):
        for g in self.galleys:
            if g.name == name or g.id == name:
                return g
        return None

    def rel(self, path):
        return os.path.relpath(path, self.root)


# ─── Generic field validation ────────────────────────────────────────────────


def _empty(v):
    return v is None or v == "" or v == [] or v == {}


def effective_legacy(schema, galley):
    """legacy: true only counts on a terminal galley (a loophole otherwise)."""
    if galley.fm.get("legacy") is not True:
        return False
    canon, _ = schema.canon("galley", galley.status)
    return bool(canon and schema.is_terminal("galley", canon))


def validate_fields(schema, spec_doc, fm, kind=None, legacy=False):
    """Check frontmatter against a schema doc. Returns [(field, message)]."""
    problems = []
    fields = spec_doc.get("fields") or {}
    for name, spec in fields.items():
        spec = spec or {}
        value = fm.get(name)
        missing = _empty(value)
        required = bool(spec.get("required"))
        rw = spec.get("required_when")
        if rw and not (spec.get("unless") == "legacy" and legacy):
            for fld, vals in rw.items():
                canon = fm.get(fld)
                if kind and fld == "status":
                    canon = schema.canon(kind, canon)[0] or canon
                if canon in (vals or []):
                    required = True
        if missing:
            if required:
                problems.append((name, "missing required field '%s'" % name))
            continue
        t = spec.get("type")
        if t == "string":
            if isinstance(value, (dict, list, bool)):
                problems.append((name, "'%s' must be text" % name))
        elif t == "date":
            if not (isinstance(value, str) and DATE_RE.match(value)):
                problems.append((name, "'%s' must be a date YYYY-MM-DD, got %r" % (name, value)))
        elif t == "bool":
            if not isinstance(value, bool):
                problems.append((name, "'%s' must be true or false, got %r" % (name, value)))
        elif t == "int":
            if isinstance(value, bool) or not isinstance(value, int) or value < 0:
                problems.append((name, "'%s' must be a non-negative integer, got %r" % (name, value)))
        elif t == "list":
            if not isinstance(value, list):
                problems.append((name, "'%s' must be a list, got %r" % (name, value)))
        elif t == "map":
            if not isinstance(value, dict):
                problems.append((name, "'%s' must be a mapping, got %r" % (name, value)))
        elif t == "enum":
            values = spec.get("values")
            if not values and spec.get("values_from"):
                sec, _, key = spec["values_from"].partition(".")
                values = list((schema.lifecycle[sec].get(key) or {}).keys())
            if kind and name == "status":
                continue  # statuses get their own, richer finding
            if value not in (values or []):
                problems.append((name, "'%s' must be one of %s, got %r" % (name, "|".join(str(v) for v in values), value)))
    for rule in spec_doc.get("rules") or []:
        when = rule.get("when") or {}
        if all(fm.get(k) == v for k, v in when.items()):
            for req in rule.get("require") or []:
                if _empty(fm.get(req)):
                    problems.append((req, "'%s' is required when %s" % (req, ", ".join("%s is %s" % kv for kv in when.items()))))
    return problems


# ─── Gate evaluation ─────────────────────────────────────────────────────────


def _verdict_problems(project, g):
    """Reasons the review.md Verdict is not an independent, passing one."""
    if g.review is None:
        return ["no review.md"]
    sec = section_text(g.review, "Verdict")
    sec = strip_html_comments(sec) if sec is not None else ""
    if not sec.strip():
        return ["no completed ## Verdict block in review.md"]
    problems = []
    by = re.search(r"^verified-by:[ \t]*(.*?)[ \t]*$", sec, flags=re.MULTILINE)
    on = re.search(r"^verified-on:[ \t]*(.*?)[ \t]*$", sec, flags=re.MULTILINE)
    build = project.engine("build")
    if not by or not by.group(1):
        problems.append("Verdict is missing verified-by:")
    elif build and by.group(1) == build:
        problems.append("verified-by '%s' equals engines.build — the builder cannot verdict its own work" % build)
    if not on or not on.group(1):
        problems.append("Verdict is missing verified-on:")
    for a in g.acs:
        if a["kind"] == "legacy" or not a["id"]:
            continue
        m = re.search(r"^%s:[ \t]*(\S.*)$" % re.escape(a["id"]), sec, flags=re.MULTILINE)
        if not m:
            problems.append("Verdict has no line for %s" % a["id"])
        elif not m.group(1).lower().startswith("pass"):
            problems.append("Verdict: %s: %s" % (a["id"], m.group(1)))
    return problems


def eval_gate(project, g, gate):
    """Failure messages for one static gate on galley g ([] = satisfied)."""
    schema = project.schema
    fm = g.fm
    if gate == "shape_complete":
        # Each section must exist AND say something (guidance in HTML comments
        # does not count); Acceptance Criteria needs at least one criterion.
        body = strip_html_comments(g.body)
        want = [("Problem", r"^##\s+problem\b"), ("Success", r"^##\s+success\b"),
                ("Approach", r"^##\s+approach\b"), ("Acceptance Criteria", r"^##\s+acceptance\b")]
        heads = [(m.start(), m.group(0)) for m in re.finditer(r"^##\s.*$", body, flags=re.MULTILINE)]
        problems = []
        for name, rx in want:
            m = re.search(rx + r".*$", body, flags=re.IGNORECASE | re.MULTILINE)
            if not m:
                problems.append("%s (missing)" % name)
                continue
            nxt = [pos for pos, _ in heads if pos > m.start()]
            section = body[m.end(): (nxt[0] if nxt else len(body))]
            if not section.strip():
                problems.append("%s (empty)" % name)
            elif name == "Acceptance Criteria" and not g.acs:
                problems.append("%s (no criteria)" % name)
        return ["galley.md sections are not filled in: %s" % ", ".join(problems)] if problems else []
    if gate == "approved":
        miss = [f for f in ("approved_by", "approved_on") if _empty(fm.get(f))]
        return ["not approved (missing %s)" % ", ".join(miss)] if miss else []
    if gate == "slugs_exist":
        return [] if g.slugs else ["no slugs — the galley has not been split"]
    if gate == "slugs_settled":
        settled = schema.section("slug").get("settled") or []
        bad = []
        for s in g.slugs:
            canon = schema.canon("slug", s.status)[0]
            if canon not in settled:
                bad.append("%s (%s)" % (s.id, s.status))
        return ["slugs not closed or dropped: %s" % ", ".join(bad)] if bad else []
    if gate == "acs_ticked":
        open_acs = unticked_acs(g.acs)
        if not g.acs:
            return ["no acceptance criteria found in galley.md"]
        if open_acs:
            names = [a["id"] or a["payload"][:40] for a in open_acs[:4]]
            more = "" if len(open_acs) <= 4 else " (+%d more)" % (len(open_acs) - 4)
            return ["%d acceptance box(es) unticked: %s%s" % (len(open_acs), "; ".join(names), more)]
        return []
    if gate == "signals_present":
        if g.review is None:
            return ["no review.md"]
        return [] if has_content(section_text(g.review, "Signals")) else ["review.md has no captured Signals"]
    if gate == "evidence":
        if g.review is None:
            return ["no review.md"]
        return [] if has_content(section_text(g.review, "Evidence")) else ["review.md has no ## Evidence (cite commits, test runs, links)"]
    if gate == "independent_review":
        return _verdict_problems(project, g)
    if gate == "learned_md":
        if g.learned is None:
            return ["learned.md is missing"]
        content = [ln for ln in strip_html_comments(g.learned).split("\n")
                   if ln.strip() and not ln.lstrip().startswith("#")]
        return [] if content else ["learned.md has no content"]
    if gate == "plan_change_logged":
        if g.plan_changes is None:
            return ["plan-changes.md is missing"]
        entries, _ = parse_plan_changes(g.plan_changes)
        return [] if entries else ["plan-changes.md has no entries"]
    if gate == "reason":
        return [] if not _empty(fm.get("closed_reason")) else ["closed_reason is not set"]
    if gate == "superseded_by":
        target = fm.get("superseded_by")
        if _empty(target):
            return ["superseded_by is not set"]
        other = project.galley_by_name(str(target))
        if other is None or other is g:
            return ["superseded_by '%s' is not another galley in this project" % target]
        return []
    if gate == "ac_check":
        return []  # dynamic — `codepress check`
    raise KeyError("no evaluator for gate %r" % gate)


def eval_slug_gate(schema, s, gate):
    if gate == "slug_acs_ticked":
        if not s.acs:
            return []
        open_acs = unticked_acs(s.acs)
        if open_acs:
            return ["%d acceptance box(es) unticked" % len(open_acs)]
        return []
    return []


def waivers(project, g):
    """Set of (from, to) canonical pairs waived in review.md, plus bare targets."""
    pairs, targets = set(), set()
    if g.review is None or project.schema.waiver_re is None:
        return pairs, targets
    for m in project.schema.waiver_re.finditer(g.review):
        a = project.schema.canon("galley", m.group(2))[0] or m.group(2)
        b = project.schema.canon("galley", m.group(3))[0] or m.group(3)
        pairs.add((a, b))
        targets.add(b)
    return pairs, targets


# ─── Lint passes ─────────────────────────────────────────────────────────────


def lint_versions(project, findings, cli_version=None):
    markers = []
    pat = re.compile(r"^codepress-version:[ \t]*(\S*)", re.MULTILINE)
    scan = []
    sysdir = os.path.join(project.cp, "system")
    for d in (project.cp, sysdir):
        if os.path.isdir(d):
            for fn in sorted(os.listdir(d)):
                if fn.endswith((".md", ".yaml", ".yml")) and os.path.isfile(os.path.join(d, fn)):
                    scan.append(os.path.join(d, fn))
    for p in scan:
        try:
            with open(p, encoding="utf-8") as fh:
                m = pat.search(fh.read())
        except (OSError, UnicodeDecodeError):
            continue
        if m:
            markers.append((project.rel(p), m.group(1)))
    for path, ver in markers:
        if not SEMVER_RE.match(ver):
            findings.append(Finding("V003", ERROR, path, "version marker %r is not a version (want MAJOR.MINOR.PATCH)" % ver))
    distinct = sorted(set(v for _, v in markers))
    if len(distinct) > 1:
        detail = "; ".join("%s says %s" % (p, v) for p, v in markers)
        findings.append(Finding("V001", ERROR, markers[0][0],
                                "version marker disagrees with itself: " + detail,
                                "Keep one marker, in .codepress/system/codepress.md."))
    elif len(markers) > 1:
        findings.append(Finding("V002", WARN, markers[1][0],
                                "version marker appears in %d files (%s)" % (len(markers), ", ".join(p for p, _ in markers)),
                                "Keep one marker, in .codepress/system/codepress.md."))
    if cli_version and len(distinct) == 1 and distinct[0] != cli_version:
        findings.append(Finding("V004", WARN, markers[0][0],
                                "project is on v%s, this CLI is v%s" % (distinct[0], cli_version),
                                "Run `codepress upgrade`."))
    return markers


def _status_finding(schema, kind, path, status, findings):
    """Validate a status value. Returns the canonical status or None."""
    canon, entry = schema.canon(kind, status)
    if canon is None:
        valid = "|".join(schema.statuses(kind))
        findings.append(Finding("G001" if kind == "galley" else "S001", ERROR, path,
                                "unknown %s status %r (valid: %s)" % (kind, status, valid)))
        return None
    if entry is not None:
        note = entry.get("note")
        extra = ""
        if entry.get("implies_approved"):
            extra += " and set approved_by"
        if entry.get("grandfather"):
            extra += " and set legacy: true"
        findings.append(Finding("G002" if kind == "galley" else "S002", ERROR, path,
                                "retired %s status %r — use %r" % (kind, status, canon),
                                "Change status to %s%s.%s" % (canon, extra, (" " + note) if note else "")))
    return canon


def lint_galley(project, g, findings, base, only_changed=False):
    schema = project.schema
    gpath = project.rel(g.path)
    if g.error:
        findings.append(Finding("F001", ERROR, gpath, "cannot parse frontmatter: %s" % g.error))
        return
    if not g.fm:
        findings.append(Finding("F002", ERROR, gpath, "no frontmatter"))
        return

    canon = None
    if g.status is None or g.status == "":
        findings.append(Finding("G003", ERROR, gpath, "missing required field 'status'"))
    else:
        canon = _status_finding(schema, "galley", gpath, g.status, findings)

    legacy = effective_legacy(schema, g)
    if g.fm.get("legacy") is True and not legacy:
        findings.append(Finding("G005", WARN, gpath, "legacy: true is only honoured on terminal galleys; ignored here"))

    for field, msg in validate_fields(schema, schema.galley_fields, g.fm, kind="galley", legacy=legacy):
        findings.append(Finding("G004", ERROR, gpath, msg))

    pairs, targets = waivers(project, g)

    # ── transition vs the base ref ──
    old_canon = None
    changed = False
    if base and canon:
        old_text = project.git.show(base, os.path.relpath(g.path, project.root))
        if old_text is None:
            initial = schema.section("galley").get("initial")
            if canon not in (initial, "shaped") and not legacy:
                findings.append(Finding("T002", WARN, gpath,
                                        "new galley created at %r, skipping the lifecycle (start at %s)" % (canon, initial)))
        else:
            try:
                old_fm, _ = miniyaml.frontmatter(old_text)
            except miniyaml.YamlError:
                old_fm = {}
            old_status = old_fm.get("status")
            old_canon = schema.canon("galley", old_status)[0] if old_status else None
            if old_status and old_status != g.status and old_canon:
                changed = True
                if old_canon != canon:
                    edge = schema.edge("galley", old_canon, canon)
                    if edge is None:
                        waived = (old_canon, canon) in pairs
                        findings.append(Finding("T001", WARN if waived else ERROR, gpath,
                                                "illegal transition %s -> %s%s" % (old_status, g.status, " (waived)" if waived else ""),
                                                "Allowed from %s: %s" % (old_canon, ", ".join(
                                                    k.split("->")[1] for k in schema.transitions("galley") if k.startswith(old_canon + "->")) or "(none — terminal)")))
                    else:
                        for r in edge.get("requires") or []:
                            if schema.gate_kind(r) != "static":
                                continue
                            for msg in eval_gate(project, g, r):
                                waived = (old_canon, canon) in pairs
                                findings.append(Finding("T003", WARN if waived else ERROR, gpath,
                                                        "%s -> %s needs %s: %s%s" % (old_status, g.status, r, msg, " (waived)" if waived else ""),
                                                        schema.gate_fix(r)))

    # ── state gates for the status the galley is at ──
    if canon and not legacy:
        for r in schema.state_requires(canon):
            if schema.gate_kind(r) != "static":
                continue
            for msg in eval_gate(project, g, r):
                waived = canon in targets
                findings.append(Finding("R001", WARN if waived else ERROR, gpath,
                                        "status %s needs %s: %s%s" % (canon, r, msg, " (waived)" if waived else ""),
                                        schema.gate_fix(r)))

    # ── plan-changes.md format ──
    if g.plan_changes is not None:
        _, errs = parse_plan_changes(g.plan_changes)
        for e in errs:
            findings.append(Finding("P001", ERROR, project.rel(os.path.join(g.dir, "plan-changes.md")), e))

    # ── slugs ──
    seen = {}
    for s in g.slugs:
        lint_slug(project, g, s, findings, seen, base)
    for s in g.slugs:
        for dep in s.fm.get("depends_on") or []:
            if str(dep) not in seen:
                findings.append(Finding("S007", ERROR, project.rel(s.path), "depends_on names unknown slug %r" % dep))

    # ── dropped slugs should leave a trace ──
    if g.slugs:
        entries = parse_plan_changes(g.plan_changes)[0] if g.plan_changes else []
        blob = "\n".join(e["title"] + "\n" + e["text"] for e in entries)
        for s in g.slugs:
            if schema.canon("slug", s.status)[0] == "dropped" and not any(n in blob for n in s.names()):
                findings.append(Finding("P003", INFO if effective_legacy(schema, g) else WARN, project.rel(s.path),
                                        "slug dropped but plan-changes.md does not mention it",
                                        "Log why in plan-changes.md."))


def lint_slug(project, g, s, findings, seen, base):
    schema = project.schema
    spath = project.rel(s.path)
    if s.error:
        findings.append(Finding("F001", ERROR, spath, "cannot parse frontmatter: %s" % s.error))
        return
    if not s.fm:
        findings.append(Finding("F002", ERROR, spath, "no frontmatter"))
        return
    if s.id in seen:
        findings.append(Finding("S006", ERROR, spath, "duplicate slug id %r (also %s)" % (s.id, project.rel(seen[s.id].path))))
    seen[s.id] = s

    canon = None
    if _empty(s.status):
        findings.append(Finding("S003", ERROR, spath, "missing required field 'status'"))
    else:
        canon = _status_finding(schema, "slug", spath, s.status, findings)

    for field, msg in validate_fields(schema, schema.slug_fields, s.fm, kind="slug"):
        if field == "galley" and not _empty(s.fm.get("galley")):
            continue
        findings.append(Finding("S004", ERROR, spath, msg))

    parent = s.fm.get("galley")
    if not _empty(parent) and str(parent) not in (g.name, g.id):
        findings.append(Finding("S005", ERROR, spath, "galley: %r but the slug lives in %s" % (parent, g.name)))

    if canon == "closed":
        for r in (schema.edge("slug", "building", "closed") or {}).get("requires") or []:
            for msg in eval_slug_gate(schema, s, r):
                legacy = effective_legacy(schema, g)
                findings.append(Finding("D001", INFO if legacy else ERROR, spath,
                                        "slug is closed but %s" % msg,
                                        "Tick the finished boxes, or reopen the slug."))
        if not has_content(section_text(s.body, "Evidence")):
            findings.append(Finding("S008", WARN, spath, "slug is closed but has no Evidence"))

    if base and canon:
        old_text = project.git.show(base, os.path.relpath(s.path, project.root))
        if old_text is not None:
            try:
                old_status = miniyaml.frontmatter(old_text)[0].get("status")
            except miniyaml.YamlError:
                old_status = None
            old_canon = schema.canon("slug", old_status)[0] if old_status else None
            if old_canon and old_canon != canon and schema.edge("slug", old_canon, canon) is None:
                findings.append(Finding("T004", ERROR, spath,
                                        "illegal slug transition %s -> %s" % (old_status, s.status)))


def _commit_galley(project, commit):
    for f in commit["files"]:
        m = re.match(r"^(?:.*/)?\.codepress/product/galleys/([^/]+)/", f)
        if m:
            return m.group(1)
    return None


def slug_commits(project):
    """{(galley_name, slug_id): [commit]} for 'slug:<name> done' commits."""
    out = {}
    if not project.git.ok:
        return out
    by_name = {}
    for g in project.galleys:
        for s in g.slugs:
            for n in s.names():
                by_name.setdefault(n, []).append((g, s))
    for c in project.git.commits():
        m = re.match(r"^slug:(\S+)\s+done\b", c["subject"])
        if not m:
            continue
        name = m.group(1)
        cands = by_name.get(name) or []
        hint = _commit_galley(project, c)
        if hint:
            cands = [(g, s) for g, s in cands if g.name == hint] or cands
        if len(cands) == 1:
            g, s = cands[0]
            out.setdefault((g.name, s.id), []).append(c)
    return out


def lint_drift(project, findings):
    """Work landed in git that the files do not admit to."""
    schema = project.schema
    sc = slug_commits(project)
    for g in project.galleys:
        if g.error or not g.fm:
            continue
        canon = schema.canon("galley", g.status)[0]
        legacy = effective_legacy(schema, g)
        sev = INFO if legacy else ERROR
        landed = 0
        for s in g.slugs:
            commits = sc.get((g.name, s.id))
            if not commits:
                continue
            landed += 1
            spath = project.rel(s.path)
            open_acs = unticked_acs(s.acs)
            when = commits[0]["date"][:10]
            sha = commits[0]["sha"][:7]
            if open_acs and schema.canon("slug", s.status)[0] != "closed":  # closed slugs: D001 already says so
                findings.append(Finding("D002", sev, spath,
                                        "drift: slug:%s done landed (%s %s) but %d acceptance box(es) are unticked" % (s.id, sha, when, len(open_acs)),
                                        "Tick the boxes the commit satisfied — or the commit message overstated."))
            settled = schema.section("slug").get("settled") or []
            if schema.canon("slug", s.status)[0] not in settled and not open_acs:
                findings.append(Finding("D003", INFO if legacy else WARN, spath,
                                        "drift: slug:%s done landed (%s %s) but the slug is still %s" % (s.id, sha, when, s.status),
                                        "Close the slug."))
        if landed and canon in ("proposed", "shaped"):
            findings.append(Finding("D004", WARN, project.rel(g.path),
                                    "drift: %d slug(s) have landed but the galley is still %s" % (landed, canon),
                                    "Move it to building (and approve it) so the status tells the truth."))
        if canon in ("proposed", "shaped") and any(a["ticked"] for a in g.acs):
            findings.append(Finding("D005", WARN, project.rel(g.path),
                                    "drift: acceptance boxes are ticked but the galley is still %s" % canon))
        if canon == "building" and g.slugs and g.acs and not legacy:
            settled = schema.section("slug").get("settled") or []
            if all(schema.canon("slug", s.status)[0] in settled for s in g.slugs) and unticked_acs(g.acs):
                findings.append(Finding("D006", WARN, project.rel(g.path),
                                        "drift: every slug is settled but %d galley-level box(es) are unticked" % len(unticked_acs(g.acs)),
                                        "Tick them, or move to verifying and let the verifier judge."))


def lint_signals(project, findings):
    schema = project.schema
    sdir = os.path.join(project.cp, "knowledge", "signals")
    if not os.path.isdir(sdir):
        return 0
    ids = {}
    count = 0
    for fn in sorted(os.listdir(sdir)):
        p = os.path.join(sdir, fn)
        if not fn.endswith(".md") or not os.path.isfile(p):
            continue
        try:
            with open(p, encoding="utf-8") as fh:
                fm, _ = miniyaml.frontmatter(fh.read())
        except (miniyaml.YamlError, OSError, UnicodeDecodeError):
            continue  # prose notes need not be valid records
        if fm.get("record") != "signal":
            continue
        count += 1
        rel = project.rel(p)
        for field, msg in validate_fields(schema, schema.signal_fields, fm):
            findings.append(Finding("N001", ERROR, rel, msg))
        sid = fm.get("id")
        if sid:
            if sid in ids:
                findings.append(Finding("N002", ERROR, rel, "duplicate signal id %r (also %s)" % (sid, ids[sid])))
            ids[sid] = rel
        gref = fm.get("galley")
        if gref:
            target = project.galley_by_name(str(gref))
            if target is None:
                findings.append(Finding("N003", WARN, rel, "signal names unknown galley %r" % gref))
            elif fm.get("status") == "open" and schema.canon("galley", target.status)[0] == "done":
                findings.append(Finding("N004", WARN, rel,
                                        "signal is still open but galley %s is done" % target.name,
                                        "Turn it into a gate or pattern, or accept the risk."))
    return count


def run_lint(project, base=None, only=None, cli_version=None):
    findings = []
    lint_versions(project, findings, cli_version)
    selected = [g for g in project.galleys if not only or g.name in only or g.id in only]
    for g in selected:
        lint_galley(project, g, findings, base)
    if not only:
        lint_drift(project, findings)
        n_signals = lint_signals(project, findings)
    else:
        n_signals = 0
    return findings, selected, n_signals


# ─── Output ──────────────────────────────────────────────────────────────────


def render(findings, galleys, n_signals, strict, quiet=False, verbose=False):
    lines = []
    n_slugs = sum(len(g.slugs) for g in galleys)
    lines.append("codepress lint — %d galleys, %d slugs, %d structured signals" % (len(galleys), n_slugs, n_signals))
    errs = [f for f in findings if f.severity == ERROR or (strict and f.severity == WARN)]
    infos = [f for f in findings if f.severity == INFO]
    warns = [f for f in findings if f not in errs and f.severity != INFO]
    order = sorted(findings, key=lambda f: (f.path, f.code))
    for f in order:
        is_err = f in errs
        if quiet and not is_err:
            continue
        if f.severity == INFO and not verbose:
            continue
        mark = "✗" if is_err else ("·" if f.severity == INFO else "⚠")
        lines.append("  %s [%s] %s: %s" % (mark, f.code, f.path, f.message))
        if f.fix:
            lines.append("       fix: %s" % f.fix)
    legacy = [g for g in galleys if effective_legacy_cached(g)]
    if legacy:
        lines.append("  (%d legacy galley(s) not gated — they predate the schema)" % len(legacy))
    if infos and not verbose:
        lines.append("  (%d legacy finding(s) hidden — rerun with --verbose)" % len(infos))
    lines.append("")
    if errs:
        lines.append("Result: ✗ FAIL — %d error(s), %d warning(s)" % (len(errs), len(warns)))
    else:
        lines.append("Result: ✓ PASS — %d warning(s)" % len(warns))
    return "\n".join(lines), len(errs)


_SCHEMA_CACHE = {}


def effective_legacy_cached(g):
    return effective_legacy(g.project.schema, g)


# ─── Status JSON ─────────────────────────────────────────────────────────────


def _days_since(iso):
    if not iso:
        return None
    try:
        d = datetime.datetime.strptime(iso[:10], "%Y-%m-%d").date()
    except ValueError:
        return None
    return (datetime.date.today() - d).days


def last_activity(project, g):
    """Latest commit that touches the galley's folder OR names the galley.

    Counting commits that merely name the galley (slug:<name> done,
    galley:<name> ...) matters: slugs often land as code commits that never
    touch the galley folder, and active work would look stalled.
    """
    best = None
    prefix = ".codepress/product/galleys/%s/" % g.name
    name_res = [re.compile(r"(?<![A-Za-z0-9_-])%s(?![A-Za-z0-9_-])" % re.escape(n)) for n in {g.name, g.id} if n]
    slug_names = set()
    for s in g.slugs:
        slug_names |= s.names()
    slug_res = [re.compile(r"^slug:%s\b" % re.escape(n)) for n in slug_names]
    for c in project.git.commits():
        hit = any(prefix in f for f in c["files"])
        if not hit:
            text = c["subject"] + "\n" + c["body"]
            hit = any(r.search(text) for r in name_res) or any(r.search(c["subject"]) for r in slug_res)
        if hit and (best is None or c["date"] > best):
            best = c["date"]
    return best


def next_action(project, g, canon):
    """(text, needs, blocked_by) for a galley — what to do and who has to do it."""
    schema = project.schema
    sections = schema.section("galley")["statuses"]
    if canon is None or schema.is_terminal("galley", canon):
        return None, "none", []
    info = sections.get(canon) or {}
    main = schema.mainline()
    blocked = []
    nxt = main[main.index(canon) + 1] if canon in main and main.index(canon) + 1 < len(main) else None
    if nxt:
        for r in (schema.edge("galley", canon, nxt) or {}).get("requires") or []:
            if schema.gate_kind(r) == "static" and eval_gate(project, g, r):
                blocked.append(r)
    settled = schema.section("slug").get("settled") or []
    if canon == "proposed":
        return info.get("next"), info.get("actor", "human"), blocked
    if canon == "shaped":
        for gate, text in (("shape_complete", "Complete the shape (missing sections)."),
                           ("slugs_exist", "Split the galley into slugs.")):
            if gate in ("shape_complete",) and eval_gate(project, g, gate):
                return text, schema.gate_actor(gate), blocked
        if not g.slugs:
            return "Split the galley into slugs.", "agent", blocked
        if "approved" in blocked:
            return "Approve the shape (`codepress galley approve %s`)." % g.name, "human", blocked
        return "Move to building.", "agent", blocked
    if canon == "building":
        open_slugs = [s for s in g.slugs if schema.canon("slug", s.status)[0] not in settled]
        if open_slugs:
            done_ids = set(s.id for s in g.slugs if schema.canon("slug", s.status)[0] in settled)
            ready = [s for s in open_slugs if all(str(d) in done_ids for d in (s.fm.get("depends_on") or []))] or open_slugs
            s = ready[0]
            auto = s.fm.get("autonomy") or "continuous"
            needs = "human" if auto in ("confirm", "stop") else "agent"
            return "Deliver slug %s." % s.id, needs, blocked
        return "Move to verifying (run `codepress check %s` first)." % g.name, "agent", blocked
    if canon == "verifying":
        for gate in ("evidence", "independent_review", "learned_md"):
            if eval_gate(project, g, gate):
                return (schema.gate_fix(gate) or "Satisfy %s." % gate), schema.gate_actor(gate), blocked
        return "Move to done.", "agent", blocked
    return info.get("next"), info.get("actor", "agent"), blocked


def status_json(project, stalled_after=14, findings=None):
    schema = project.schema
    by_path = {}
    for f in findings or []:
        by_path.setdefault(f.path, []).append(f)
    rows = []
    for g in project.galleys:
        canon = schema.canon("galley", g.status)[0] if g.status else None
        counts = {"total": len(g.slugs), "open": 0, "building": 0, "closed": 0, "dropped": 0}
        for s in g.slugs:
            c = schema.canon("slug", s.status)[0]
            if c in counts:
                counts[c] += 1
        ticked = len([a for a in g.acs if a["ticked"]])
        la = last_activity(project, g)
        days = _days_since(la)
        text, needs, blocked = next_action(project, g, canon)
        gp = project.rel(g.path)
        fl = [f for f in (findings or []) if f.path.startswith(project.rel(g.dir) + os.sep)]
        terminal = bool(canon and schema.is_terminal("galley", canon))
        rows.append({
            "id": g.id,
            "dir": g.name,
            "title": g.title(),
            "status": canon or g.status,
            "raw_status": g.status,
            "retired_status": bool(canon and canon != g.status),
            "legacy": effective_legacy(schema, g),
            "domain": g.fm.get("domain"),
            "approved": not _empty(g.fm.get("approved_by")),
            "slugs": counts,
            "acceptance": {"total": len(g.acs), "ticked": ticked},
            "last_activity": la,
            "days_since_activity": days,
            "stalled": bool(days is not None and not terminal and canon not in (None,) and days > stalled_after),
            "next_action": text,
            "needs": needs,
            "blocked_by": blocked,
            "findings": {
                "errors": len([f for f in fl if f.severity == ERROR]),
                "warnings": len([f for f in fl if f.severity == WARN]),
            },
        })
    summary = {}
    for r in rows:
        summary[r["status"]] = summary.get(r["status"], 0) + 1
    return {
        "generated": datetime.datetime.now().replace(microsecond=0).isoformat(),
        "galleys": rows,
        "summary": {"by_status": summary, "total": len(rows),
                    "needs_human": len([r for r in rows if r["needs"] == "human"]),
                    "stalled": len([r for r in rows if r["stalled"]])},
    }


# ─── Status migration ────────────────────────────────────────────────────────


def _fmt_value(v):
    v = str(v)
    if re.search(r"[:#\[\]{}]", v) or v[:1] in ("'", '"'):
        return '"%s"' % v.replace('"', "'")
    return v


def edit_frontmatter(text, updates):
    """Set top-level frontmatter keys, preserving everything else."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return text
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return text
    for key, value in updates.items():
        new = "%s: %s" % (key, _fmt_value(value))
        for i in range(1, end):
            if re.match(r"^%s:" % re.escape(key), lines[i]):
                lines[i] = new
                break
        else:
            lines.insert(end, new)
            end += 1
    return "\n".join(lines)


def plan_migration(project):
    """What it would take to move a project onto the lifecycle vocabulary."""
    schema = project.schema
    today = datetime.date.today().isoformat()
    plan = []
    for g in project.galleys:
        if g.error or not g.fm:
            continue
        raw = g.status
        canon, entry = schema.canon("galley", raw)
        if canon is None:
            plan.append({"path": g.path, "label": "galley %s" % g.name, "note": "unknown status %r — resolve by hand" % raw, "updates": {}})
            continue
        updates, notes = {}, []
        if entry is not None:
            updates["status"] = canon
            updates["legacy_status"] = raw
            if entry.get("judgment"):
                notes.append("judgment call")
        main = schema.mainline()
        past_approval = canon in main and main.index(canon) >= main.index("building")
        terminal_now = schema.is_terminal("galley", canon)
        # A pre-schema galley that was already past approval was approved by
        # definition; terminal ones are grandfathered whole, so skip them here.
        if not terminal_now and (past_approval or (entry and entry.get("implies_approved"))) and _empty(g.fm.get("approved_by")):
            updates["approved_by"] = "legacy"
            updates["approved_on"] = str(g.fm.get("created") or today)
        if schema.is_terminal("galley", canon) and g.fm.get("legacy") is not True:
            probe = Galley.__new__(Galley)
            probe.__dict__.update(g.__dict__)
            probe.fm = dict(g.fm)
            unmet = []
            for r in schema.state_requires(canon):
                if schema.gate_kind(r) == "static":
                    unmet.extend(eval_gate(project, probe, r))
            if unmet:
                updates["legacy"] = "true"
                notes.append("grandfathered: %d terminal gate(s) unmet" % len(unmet))
            if canon == "killed" and _empty(g.fm.get("closed_reason")):
                updates["closed_reason"] = "migrated from legacy status '%s'; reason not recorded" % raw
        if updates:
            plan.append({"path": g.path, "label": "galley %s" % g.name,
                         "change": "%s -> %s" % (raw, canon), "updates": updates, "notes": notes})
        for sl in g.slugs:
            if sl.error or not sl.fm:
                continue
            sc, se = schema.canon("slug", sl.status)
            if se is not None and sc:
                plan.append({"path": sl.path, "label": "slug %s/%s" % (g.name, sl.stem),
                             "change": "%s -> %s" % (sl.status, sc), "updates": {"status": sc},
                             "notes": ["judgment call"] if se.get("judgment") else []})
    return plan


def cmd_migrate(args):
    schema = Schema()
    project = Project(args.root, schema)
    plan = plan_migration(project)
    if not plan:
        print("migrate-status: nothing to migrate — every status is already canonical.")
        return 0
    judgment = 0
    for item in plan:
        extra = ", ".join("%s: %s" % (k, v) for k, v in item["updates"].items() if k != "status")
        notes = item.get("notes") or []
        judgment += 1 if "judgment call" in notes else 0
        print("  %-48s %s%s%s" % (item["label"], item.get("change", item.get("note", "")),
                                  ("  (+ %s)" % extra) if extra else "",
                                  ("  [%s]" % "; ".join(notes)) if notes else ""))
    print("")
    print("%d file(s) to change, %d judgment call(s)." % (len([i for i in plan if i["updates"]]), judgment))
    if not args.apply:
        print("Dry run. Review the mapping (schema/lifecycle.yaml `legacy:`), then re-run with --apply.")
        return 0
    n = 0
    for item in plan:
        if not item["updates"]:
            continue
        with open(item["path"], encoding="utf-8") as fh:
            text = fh.read()
        new = edit_frontmatter(text, item["updates"])
        if new != text:
            with open(item["path"], "w", encoding="utf-8") as fh:
                fh.write(new)
            n += 1
    print("Applied: %d file(s) edited. Now run `codepress lint`." % n)
    return 0


# ─── Command line ────────────────────────────────────────────────────────────


def mapping_table(schema):
    out = ["| Kind | Legacy value | Becomes | Also | Note |", "|---|---|---|---|---|"]
    for kind in ("galley", "slug"):
        for old, e in schema.legacy_map(kind).items():
            also = []
            if e.get("implies_approved"):
                also.append("approved_by: legacy")
            if e.get("grandfather"):
                also.append("legacy: true")
            if e.get("judgment"):
                also.append("**judgment call**")
            out.append("| %s | `%s` | `%s` | %s | %s |" % (kind, old, e.get("to"), "; ".join(also), e.get("note") or ""))
    return "\n".join(out)


def cmd_lint(args):
    schema = Schema()
    project = Project(args.root, schema)
    base = args.base
    if base == "none":
        base = None
    elif base is None:
        base = "HEAD" if project.git.has_ref("HEAD") else None
    elif not project.git.has_ref(base):
        print("lint: base ref %r not found" % base, file=sys.stderr)
        return 2
    findings, galleys, n_signals = run_lint(project, base, args.galley or None, args.cli_version)
    errs = [f for f in findings if f.severity == ERROR or (args.strict and f.severity == WARN)]
    if args.json:
        print(json.dumps({
            "ok": not errs,
            "base": base,
            "galleys": len(galleys),
            "findings": [f.as_dict() for f in findings],
        }, indent=2))
        return 1 if errs else 0
    text, n_err = render(findings, galleys, n_signals, args.strict, args.quiet, args.verbose)
    print(text)
    return 1 if n_err else 0


def main(argv=None):
    p = argparse.ArgumentParser(prog="lint.py", add_help=True)
    sub = p.add_subparsers(dest="cmd")

    sp = sub.add_parser("lint")
    sp.add_argument("--root", default=".")
    sp.add_argument("--base", default=None, help="git ref to compare statuses against (default HEAD; 'none' disables)")
    sp.add_argument("--strict", action="store_true", help="treat warnings as errors")
    sp.add_argument("--json", action="store_true")
    sp.add_argument("--quiet", action="store_true", help="show errors only")
    sp.add_argument("--verbose", action="store_true", help="also show legacy (info) findings")
    sp.add_argument("--galley", action="append")
    sp.add_argument("--cli-version", default=None)

    sj = sub.add_parser("status-json")
    sj.add_argument("--root", default=".")
    sj.add_argument("--stalled-after", type=int, default=14)

    sc = sub.add_parser("canon")
    sc.add_argument("kind", choices=["galley", "slug"])
    sc.add_argument("status")

    sa = sub.add_parser("aliases")
    sa.add_argument("kind", choices=["galley", "slug"])

    sub.add_parser("table")

    sm = sub.add_parser("migrate")
    sm.add_argument("--root", default=".")
    sm.add_argument("--apply", action="store_true")

    se = sub.add_parser("eval")
    se.add_argument("galley")
    se.add_argument("gates", nargs="+")
    se.add_argument("--root", default=".")

    sr = sub.add_parser("requires")
    sr.add_argument("src")
    sr.add_argument("dst")

    sg = sub.add_parser("gate")
    sg.add_argument("galley")
    sg.add_argument("src")
    sg.add_argument("dst")
    sg.add_argument("--root", default=".")

    sx = sub.add_parser("acs")
    sx.add_argument("file")

    sub.add_parser("mapping")
    sub.add_parser("check-schema")

    args = p.parse_args(argv)
    try:
        if args.cmd == "lint":
            return cmd_lint(args)
        schema = Schema()
        if args.cmd == "status-json":
            project = Project(args.root, schema)
            base = "HEAD" if project.git.has_ref("HEAD") else None
            findings, _, _ = run_lint(project, base)
            print(json.dumps(status_json(project, args.stalled_after, findings), indent=2))
            return 0
        if args.cmd == "canon":
            canon, entry = schema.canon(args.kind, args.status)
            if canon is None:
                return 1
            flags = []
            if entry and entry.get("implies_approved"):
                flags.append("approved")
            if entry and entry.get("grandfather"):
                flags.append("legacy")
            print(canon + (" " + ",".join(flags) if flags else ""))
            return 0
        if args.cmd == "migrate":
            return cmd_migrate(args)
        if args.cmd == "table":
            # kind status canonical flags — every canonical and retired value, so
            # shell callers resolve statuses with one process start.
            for kind in ("galley", "slug"):
                settled = schema.section("slug").get("settled") or []
                for st in schema.statuses(kind):
                    flags = []
                    if kind == "slug" and st in settled:
                        flags.append("settled")
                    if schema.is_terminal(kind, st):
                        flags.append("terminal")
                    print("%s %s %s %s" % (kind, st, st, ",".join(flags) or "-"))
                for old, e in schema.legacy_map(kind).items():
                    flags = ["retired"]
                    if e.get("implies_approved"):
                        flags.append("approved")
                    if e.get("grandfather"):
                        flags.append("legacy")
                    if kind == "slug" and e["to"] in settled:
                        flags.append("settled")
                    print("%s %s %s %s" % (kind, old, e["to"], ",".join(flags)))
            return 0
        if args.cmd == "eval":
            project = Project(args.root, schema)
            g = project.galley_by_name(args.galley)
            if g is None:
                print("eval: galley %r not found" % args.galley, file=sys.stderr)
                return 2
            bad = 0
            for gate in args.gates:
                if gate not in schema.gates:
                    print("eval: unknown gate %r" % gate, file=sys.stderr)
                    return 2
                for msg in eval_gate(project, g, gate):
                    print("  ✗ %s: %s" % (gate, msg))
                    bad += 1
            return 1 if bad else 0
        if args.cmd == "aliases":
            for old, e in schema.legacy_map(args.kind).items():
                flags = []
                if e.get("implies_approved"):
                    flags.append("approved")
                if e.get("grandfather"):
                    flags.append("legacy")
                print("%s=%s%s" % (old, e["to"], (" " + ",".join(flags)) if flags else ""))
            return 0
        if args.cmd == "requires":
            edge = schema.edge("galley", args.src, args.dst)
            if edge is None:
                return 1
            for r in edge.get("requires") or []:
                print("%s %s" % (r, schema.gate_kind(r)))
            return 0
        if args.cmd == "gate":
            project = Project(args.root, schema)
            g = project.galley_by_name(args.galley)
            if g is None:
                print("gate: galley %r not found" % args.galley, file=sys.stderr)
                return 2
            a = schema.canon("galley", args.src)[0] or args.src
            b = schema.canon("galley", args.dst)[0] or args.dst
            edge = schema.edge("galley", a, b)
            if edge is None:
                print("illegal transition %s -> %s (allowed from %s: %s)" % (
                    a, b, a, ", ".join(k.split("->")[1] for k in schema.transitions("galley") if k.startswith(a + "->")) or "(none — terminal)"))
                return 3
            bad = 0
            for r in edge.get("requires") or []:
                if schema.gate_kind(r) != "static":
                    continue
                for msg in eval_gate(project, g, r):
                    print("  ✗ %s: %s" % (r, msg))
                    fix = schema.gate_fix(r)
                    if fix:
                        print("      fix: %s" % fix)
                    bad += 1
            return 1 if bad else 0
        if args.cmd == "acs":
            with open(args.file, encoding="utf-8") as fh:
                for a in parse_acs(fh.read()):
                    print("%s|%s|%s|%d" % (a["id"], a["kind"], a["payload"], 1 if a["ticked"] else 0))
            return 0
        if args.cmd == "mapping":
            print(mapping_table(schema))
            return 0
        if args.cmd == "check-schema":
            problems = schema.check()
            for pr in problems:
                print("schema: " + pr)
            if not problems:
                print("schema: ok")
            return 1 if problems else 0
    except (miniyaml.YamlError, KeyError, OSError) as exc:
        print("lint: %s" % exc, file=sys.stderr)
        return 2
    p.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
