#!/usr/bin/env python3

import ast
import os
import re
import sys

ALLOWED = set(sys.stdlib_module_names) | set(sys.builtin_module_names) | {"boto3", "botocore"}


def get_imports(filepath):
    with open(filepath, encoding="utf-8") as fh:
        source = fh.read()
    try:
        tree = ast.parse(source, filename=filepath)
    except SyntaxError:
        return set()
    imports = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.add(alias.name.split(".")[0])
        elif isinstance(node, ast.ImportFrom):
            if node.level == 0 and node.module:
                imports.add(node.module.split(".")[0])
    return imports


def extract_block_body(content, start):
    depth = 0
    body_start = -1
    for i, ch in enumerate(content[start:], start):
        if ch == "{":
            depth += 1
            if depth == 1:
                body_start = i + 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return content[body_start:i]
    return content[body_start:] if body_start != -1 else ""


def find_python_sources(tf_file):
    tf_dir = os.path.dirname(tf_file)
    with open(tf_file, encoding="utf-8") as fh:
        content = fh.read()
    sources = []
    for m in re.finditer(r'data\s+"archive_file"\s+"[^"]+"\s*(\{)', content):
        body = extract_block_body(content, m.start(1))
        for py_m in re.finditer(r'(?:content\s*=\s*file\s*\(\s*|source_file\s*=\s*)"([^"]+\.py)"', body):
            rel = re.sub(r"^\$\{path\.module\}/", "", py_m.group(1))
            sources.append(os.path.normpath(os.path.join(tf_dir, rel)))
    return sources


def has_lambda_layer(module_dir):
    patterns = [
        re.compile(r'resource\s+"aws_lambda_layer_version"'),
        re.compile(r'\blayers\s*=\s*\['),
    ]
    for entry in os.listdir(module_dir):
        if not entry.endswith(".tf"):
            continue
        try:
            with open(os.path.join(module_dir, entry), encoding="utf-8") as fh:
                content = fh.read()
        except OSError:
            continue
        if any(p.search(content) for p in patterns):
            return True
    return False


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.getcwd())
    print(f"Checking Lambda Python dependencies in: {root}\n")
    violations = 0

    for dirpath, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if not d.startswith(".") and d not in ("node_modules", ".terraform")]
        for filename in files:
            if not filename.endswith(".tf"):
                continue
            tf_file = os.path.join(dirpath, filename)
            sources = find_python_sources(tf_file)
            if not sources:
                continue
            layer_backed = has_lambda_layer(dirpath)
            for py_file in sources:
                rel = os.path.relpath(py_file, root)
                if layer_backed:
                    print(f"[OK]   {rel} (layer-backed module)")
                    continue
                third_party = get_imports(py_file) - ALLOWED
                if third_party:
                    print(f"[FAIL] {rel} imports unbundled 3rd party package(s): {', '.join(sorted(third_party))}")
                    violations += 1
                else:
                    print(f"[OK]   {rel}")

    print()
    if violations:
        print(f"FAILED: {violations} Lambda Python file(s) use unbundled 3rd party dependencies.")
        sys.exit(1)
    print("PASSED: All Lambda Python files only use allowed imports.")


if __name__ == "__main__":
    main()

