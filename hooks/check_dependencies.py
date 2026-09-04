#!/usr/bin/env python3

import argparse
import glob
import json
import os
import re
import sys
from pathlib import Path


ENVIRONMENT_VARIABLE = re.compile(r"\$(?:[A-Za-z_][A-Za-z0-9_]*|\{[^}]+\})")


class ConfigurationError(Exception):
    pass


def read_string_array(path: Path) -> list[str]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except OSError as error:
        raise ConfigurationError(f"cannot read {path}: {error}") from error
    except json.JSONDecodeError as error:
        raise ConfigurationError(
            f"invalid JSON in {path}:{error.lineno}:{error.colno}: {error.msg}"
        ) from error

    if not isinstance(data, list) or any(not isinstance(item, str) for item in data):
        raise ConfigurationError(f"{path} must contain a JSON array of strings")

    return data


def read_dependency_patterns(path: Path) -> list[str]:
    try:
        contents = path.read_text(encoding="utf-8")
    except OSError as error:
        raise ConfigurationError(f"cannot read {path}: {error}") from error

    try:
        data = json.loads(contents)
    except json.JSONDecodeError:
        return [
            line.strip()
            for line in contents.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        ]

    if not isinstance(data, list) or any(not isinstance(item, str) for item in data):
        raise ConfigurationError(
            f"{path} must contain paths separated by newlines or a JSON array of paths"
        )

    return data


def resolve_provider_files(
    patterns: list[str], base_directory: Path
) -> tuple[list[Path], list[str]]:
    provider_files: list[Path] = []
    errors: list[str] = []

    for pattern in patterns:
        expanded_pattern = os.path.expanduser(os.path.expandvars(pattern))
        unresolved_variables = ENVIRONMENT_VARIABLE.findall(expanded_pattern)
        if unresolved_variables:
            errors.append(
                f"unresolved environment variable in dependency path {pattern!r}: "
                + ", ".join(unresolved_variables)
            )
            continue

        dependency_path = Path(expanded_pattern)
        if not dependency_path.is_absolute():
            dependency_path = base_directory / dependency_path

        matches = [Path(match) for match in sorted(glob.glob(str(dependency_path)))]
        if not matches:
            errors.append(f"dependency path did not match a file: {pattern}")
            continue

        for match in matches:
            if not match.is_file():
                errors.append(f"dependency path is not a file: {match}")
            elif match not in provider_files:
                provider_files.append(match)

    return provider_files, errors


def check_dependencies(deps_directory: Path) -> int:
    requires_path = deps_directory / "requires.json"
    provides_path = deps_directory / "provides.json"
    dependencies_path = deps_directory / "dependencies.json"

    requirements = read_string_array(requires_path)
    dependency_patterns = read_dependency_patterns(dependencies_path)
    dependency_files, errors = resolve_provider_files(
        dependency_patterns, dependencies_path.parent
    )

    provider_files = [provides_path, *dependency_files]
    providers: dict[str, Path] = {}
    loaded_provider_files = 0
    for provider_file in provider_files:
        try:
            capabilities = read_string_array(provider_file)
        except ConfigurationError as error:
            errors.append(str(error))
            continue
        loaded_provider_files += 1
        for capability in capabilities:
            providers.setdefault(capability, provider_file)

    missing = [requirement for requirement in requirements if requirement not in providers]

    for requirement in requirements:
        provider = providers.get(requirement)
        if provider is None:
            print(f"MISSING {requirement}")
        else:
            print(f"OK      {requirement} <- {provider}")

    print(
        f"\nSatisfied {len(requirements) - len(missing)}/{len(requirements)} "
        f"requirements using {loaded_provider_files} provider file(s)."
    )
    sys.stdout.flush()

    if errors:
        print("\nConfiguration errors:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)

    if missing:
        print("\nUnsatisfied requirements:", file=sys.stderr)
        for requirement in missing:
            print(f"  - {requirement}", file=sys.stderr)

    if errors:
        return 2
    return 1 if missing else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Check requires.json against provides.json and the provider files "
            "listed in dependencies.json."
        )
    )
    parser.add_argument(
        "directory",
        nargs="?",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="directory containing the three dependency files (default: script directory)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        return check_dependencies(args.directory.resolve())
    except ConfigurationError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
