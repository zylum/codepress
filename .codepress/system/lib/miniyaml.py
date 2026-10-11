"""miniyaml — the small YAML subset CodePress reads, with no dependencies.

CodePress artefacts keep their state in flat, human-edited frontmatter, and its
schema files are written in the same dialect, so one tiny parser serves both.

Supported:
  - block mappings            key: value
  - block sequences           - item            (scalars or mappings)
  - flow sequences/mappings   [a, b]   {k: v, k2: v2}   (scalars only, one level)
  - scalars                   strings, "quoted", 'quoted', ints, floats, true/false,
                              null / ~ / empty
  - comments                  # to end of line (when preceded by whitespace)
  - folded/literal blocks     key: >  /  key: |   (returned as one string)

Not supported (on purpose): anchors, tags, multi-document streams, complex keys.
Anything outside the subset raises YamlError rather than being guessed at.
"""

import re


class YamlError(ValueError):
    pass


_INT = re.compile(r"^[-+]?\d+$")
_FLOAT = re.compile(r"^[-+]?\d+\.\d+$")


def _strip_comment(line):
    """Remove a trailing ' # comment', respecting quotes."""
    out = []
    quote = None
    for i, ch in enumerate(line):
        if quote:
            out.append(ch)
            if ch == quote:
                quote = None
            continue
        if ch in ("'", '"') and (i == 0 or line[i - 1] in " \t[{,:"):
            quote = ch
            out.append(ch)
            continue
        if ch == "#" and (i == 0 or line[i - 1] in " \t"):
            break
        out.append(ch)
    return "".join(out).rstrip()


def _scalar(text):
    t = text.strip()
    if t == "" or t == "~" or t.lower() == "null":
        return None
    if len(t) >= 2 and t[0] == t[-1] and t[0] in ("'", '"'):
        return t[1:-1]
    low = t.lower()
    if low == "true":
        return True
    if low == "false":
        return False
    if _INT.match(t):
        return int(t)
    if _FLOAT.match(t):
        return float(t)
    return t


def _split_flow(body):
    """Split a flow body on top-level commas, respecting quotes."""
    parts, cur, quote = [], [], None
    for ch in body:
        if quote:
            cur.append(ch)
            if ch == quote:
                quote = None
        elif ch in ("'", '"'):
            quote = ch
            cur.append(ch)
        elif ch == ",":
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur)
    if tail.strip() or parts:
        parts.append(tail)
    return [p for p in parts if p.strip() != ""]


def _flow(text):
    t = text.strip()
    if t.startswith("[") and t.endswith("]"):
        return [_scalar(p) for p in _split_flow(t[1:-1])]
    if t.startswith("{") and t.endswith("}"):
        result = {}
        for part in _split_flow(t[1:-1]):
            if ":" not in part:
                raise YamlError("bad flow mapping entry: %r" % part)
            k, _, v = part.partition(":")
            result[_scalar(k)] = _scalar(v)
        return result
    return _scalar(t)


def _value(text):
    t = text.strip()
    if t.startswith("[") or t.startswith("{"):
        if not (t.endswith("]") or t.endswith("}")):
            raise YamlError("unterminated flow collection: %r" % t)
        return _flow(t)
    return _scalar(t)


_KEY = re.compile(r"""^((?:"[^"]*"|'[^']*'|[^\s:'"#][^:]*?))\s*:(?:\s+(.*)|)$""")


def _split_key(text):
    """Return (key, rest) if text is 'key: rest' / 'key:', else None."""
    m = _KEY.match(text)
    if not m:
        return None
    key = m.group(1).strip()
    if len(key) >= 2 and key[0] == key[-1] and key[0] in ("'", '"'):
        key = key[1:-1]
    return key, (m.group(2) or "")


class _Lines:
    def __init__(self, text):
        self.items = []  # (indent, content)
        for raw in text.splitlines():
            if "\t" in raw[: len(raw) - len(raw.lstrip())]:
                raise YamlError("tab indentation is not supported")
            stripped = _strip_comment(raw)
            if not stripped.strip():
                continue
            indent = len(stripped) - len(stripped.lstrip(" "))
            self.items.append((indent, stripped.strip()))
        self.pos = 0

    def peek(self):
        return self.items[self.pos] if self.pos < len(self.items) else None

    def next(self):
        item = self.items[self.pos]
        self.pos += 1
        return item


def _block_scalar(lines, parent_indent, style):
    """Consume the more-indented continuation lines of a >/| scalar."""
    chunks = []
    while lines.peek() is not None and lines.peek()[0] > parent_indent:
        chunks.append(lines.next()[1])
    return (" " if style == ">" else "\n").join(chunks)


def _is_dash(content):
    return content.startswith("- ") or content == "-"


def _parse_block(lines, indent):
    first = lines.peek()
    if first is None or first[0] < indent:
        return None
    if _is_dash(first[1]):
        return _parse_seq(lines, first[0])
    return _parse_map(lines, first[0])


def _parse_seq(lines, indent):
    result = []
    while True:
        item = lines.peek()
        if item is None or item[0] != indent or not _is_dash(item[1]):
            break
        lines.next()
        rest = item[1][1:].strip()
        if rest == "":
            result.append(_parse_block(lines, indent + 1))
            continue
        kv = None if rest.startswith(("[", "{", '"', "'")) else _split_key(rest)
        if kv:
            # "- key: value" opens a mapping whose further keys align with the
            # first key (two columns right of the dash).
            key_indent = indent + 2
            entry = {}
            entry[kv[0]] = _map_value(lines, key_indent, kv[1])
            nxt = lines.peek()
            while nxt is not None and nxt[0] == key_indent and not _is_dash(nxt[1]):
                lines.next()
                pair = _split_key(nxt[1])
                if not pair:
                    raise YamlError("expected 'key: value', got %r" % nxt[1])
                entry[pair[0]] = _map_value(lines, key_indent, pair[1])
                nxt = lines.peek()
            result.append(entry)
        else:
            result.append(_value(rest))
    return result


def _map_value(lines, key_indent, rest):
    rest = rest.strip()
    if rest in (">", "|", ">-", "|-"):
        return _block_scalar(lines, key_indent, rest[0])
    if rest == "":
        nxt = lines.peek()
        if nxt is not None and (
            nxt[0] > key_indent or (nxt[0] == key_indent and _is_dash(nxt[1]))
        ):
            return _parse_block(lines, nxt[0])
        return None
    return _value(rest)


def _parse_map(lines, indent):
    result = {}
    while True:
        item = lines.peek()
        if item is None:
            break
        if item[0] > indent:
            raise YamlError("unexpected indentation at %r" % item[1])
        if item[0] < indent or _is_dash(item[1]):
            break
        pair = _split_key(item[1])
        if not pair:
            raise YamlError("expected 'key: value', got %r" % item[1])
        lines.next()
        result[pair[0]] = _map_value(lines, indent, pair[1])
    return result


def loads(text):
    """Parse a YAML-subset document into dicts / lists / scalars."""
    lines = _Lines(text)
    if lines.peek() is None:
        return {}
    value = _parse_block(lines, lines.peek()[0])
    if lines.peek() is not None:
        raise YamlError("could not parse near %r" % (lines.peek()[1],))
    return value


def load(path):
    with open(path, encoding="utf-8") as fh:
        return loads(fh.read())


def split_frontmatter(text):
    """Return (frontmatter_text | None, body_text) for a markdown file."""
    if not text.startswith("---"):
        return None, text
    lines = text.split("\n")
    if lines[0].strip() != "---":
        return None, text
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return "\n".join(lines[1:i]), "\n".join(lines[i + 1:])
    return None, text


def frontmatter(text):
    """Parse a markdown file's frontmatter. Returns ({}, body) when absent."""
    fm, body = split_frontmatter(text)
    if fm is None:
        return {}, body
    data = loads(fm)
    if data is None:
        data = {}
    if not isinstance(data, dict):
        raise YamlError("frontmatter must be a mapping")
    return data, body
