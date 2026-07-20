#!/usr/bin/env python3
"""Regenerate the Obsidian "Code Graph" from real Dart imports.

Run manually:  python3 tool/build_obsidian_graph.py
Used by the `Stop` hook in .claude/settings.json to keep the vault fresh.

Design goals:
- Cheap no-op when no .dart file changed (mtime signature guard).
- Writes a note only if its content actually changed (no Obsidian re-index storm).
- Removes notes for deleted .dart files, prunes empty dirs.
- Never crashes the hook: always exits 0.
"""
import os, re, sys, hashlib

# ── Config ────────────────────────────────────────────────────────────────
PKG = "hero"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "lib"))
VAULT = os.environ.get(
    "HERO_OBSIDIAN_VAULT",
    "/Users/crizalis_xd/Desktop/hero v1.01/Hero-Obsidian-Vault",
)
CODE_GRAPH = os.path.join(VAULT, "Code Graph")
STATE_FILE = os.path.join(CODE_GRAPH, ".graph_state")

import_re = re.compile(r"""^\s*(?:import|export|part)\s+['"]([^'"]+)['"]""")


def die_ok(msg):
    print(msg)
    sys.exit(0)


def collect_dart():
    files = {}
    for root, _, names in os.walk(LIB):
        for n in names:
            if n.endswith(".dart"):
                ap = os.path.join(root, n)
                rel = os.path.relpath(ap, LIB)[:-5]  # strip .dart
                files[rel] = ap
    return files


def signature(dart_files):
    h = hashlib.sha256()
    for rel in sorted(dart_files):
        try:
            mt = os.path.getmtime(dart_files[rel])
        except OSError:
            mt = 0
        h.update(f"{rel}:{mt}\n".encode())
    return h.hexdigest()


def gen_base(p, dart_files):
    for suf in (".g", ".freezed"):
        if p.endswith(suf):
            base = p[: -len(suf)]
            if base in dart_files:
                return base
    return None


def resolve(cur_rel, target, dart_files):
    if target.startswith("package:"):
        if not target.startswith(f"package:{PKG}/"):
            return None
        p = target[len(f"package:{PKG}/"):]
        if p.endswith(".dart"):
            p = p[:-5]
        return p if p in dart_files else gen_base(p, dart_files)
    if target.startswith("dart:"):
        return None
    if "/" in target or target.startswith(".") or target.endswith(".dart"):
        p = os.path.normpath(os.path.join(os.path.dirname(cur_rel), target))
        if p.endswith(".dart"):
            p = p[:-5]
        return p if p in dart_files else gen_base(p, dart_files)
    return None


def meta(rel):
    parts = rel.split(os.sep)
    tags = ["hero", "dartfile"]
    feature = layer = None
    if parts[0] == "features" and len(parts) >= 3:
        feature, layer = parts[1], parts[2]
        tags += [f"feature/{feature}", f"layer/{layer}"]
    elif parts[0] == "core":
        tags.append("core")
    elif parts[0] == "app":
        tags.append("app")
    return tags, feature, layer


def note_body(rel, targets):
    tags, feature, layer = meta(rel)
    fm = "---\ntags: [" + ", ".join(tags) + "]\n"
    if feature:
        fm += f"feature: {feature}\n"
    if layer:
        fm += f"layer: {layer}\n"
    fm += f"path: lib/{rel}.dart\n---\n\n"
    body = f"# `{os.path.basename(rel)}.dart`\n\n> `lib/{rel}.dart`\n\n"
    if targets:
        body += f"## Импортирует ({len(targets)})\n"
        for t in sorted(targets):
            body += f"- [[{t}|{os.path.basename(t)}]]\n"
    else:
        body += "_Нет внутренних импортов (только внешние пакеты / dart SDK)._\n"
    return fm + body


def write_if_changed(path, content):
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            if f.read() == content:
                return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return True


def main():
    if not os.path.isdir(LIB):
        die_ok(f"[obsidian-graph] lib not found at {LIB}; skip.")
    if not os.path.isdir(VAULT):
        die_ok(f"[obsidian-graph] vault not found at {VAULT}; skip.")

    dart_files = collect_dart()
    sig = signature(dart_files)
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, encoding="utf-8") as f:
            if f.read().strip() == sig:
                die_ok("[obsidian-graph] no .dart changes; skip.")

    desired = set()
    changed = 0
    for rel, ap in dart_files.items():
        try:
            with open(ap, encoding="utf-8") as fh:
                src = fh.read()
        except OSError:
            continue
        targets = []
        for line in src.splitlines():
            m = import_re.match(line)
            if not m:
                continue
            r = resolve(rel, m.group(1), dart_files)
            if r and r != rel and r in dart_files and r not in targets:
                targets.append(r)
        path = os.path.join(CODE_GRAPH, rel + ".md")
        desired.add(os.path.normpath(path))
        if write_if_changed(path, note_body(rel, targets)):
            changed += 1

    # prune orphan notes (deleted .dart) + empty dirs
    removed = 0
    for root, _, names in os.walk(CODE_GRAPH):
        for n in names:
            if n.endswith(".md"):
                p = os.path.normpath(os.path.join(root, n))
                if p not in desired:
                    os.remove(p)
                    removed += 1
    for root, dirs, files in os.walk(CODE_GRAPH, topdown=False):
        if root != CODE_GRAPH and not os.listdir(root):
            os.rmdir(root)

    os.makedirs(CODE_GRAPH, exist_ok=True)
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        f.write(sig)
    print(f"[obsidian-graph] notes={len(dart_files)} written={changed} removed={removed}")
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # never break the hook
        die_ok(f"[obsidian-graph] error: {e}; skip.")
