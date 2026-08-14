#!/usr/bin/python3
"""
RPM Dependency Checker using rpm.labelCompare
Validates that all requirements in requires.json are satisfied by provides.json
"""

import json
import re
import rpm
import sys
import os
from shlex import quote

def parse_rpm_dependency(dep_string):
    """
    Parse an RPM dependency string into components.

    Examples:
        "package-name >= 1.2.3-1" -> ("package-name", ">=", "1.2.3-1")
        "package-name" -> ("package-name", None, None)
        "package-name = 1:2.3.4-5" -> ("package-name", "=", "1:2.3.4-5")

    Returns:
        tuple: (name, operator, version) where operator and version may be None
    """
    # Pattern to match: name [operator version]
    # We explicitly look for the operator to avoid splitting simple names
    pattern = r'^(.+?)\s*([<>=]+)\s*(\S+)$'
    match = re.match(pattern, dep_string.strip())

    if match:
        name = match.group(1).strip()
        operator = match.group(2).strip()
        version = match.group(3).strip()
        return (name, operator, version)
    else:
        # No operator found, assume it is just the name (capability)
        return (dep_string.strip(), None, None)


def split_evr(version_string):
    """
    Split version string into (epoch, version, release).

    Examples:
        "1:2.3.4-5" -> ("1", "2.3.4", "5")
        "2.3.4-5" -> ("", "2.3.4", "5")
        "2.3.4" -> ("", "2.3.4", "")

    Returns:
        tuple: (epoch, version, release)
    """
    if not version_string:
        return ("", "", "")

    epoch = ""
    version = version_string
    release = ""
    if ':' in version_string:
        epoch, version_string = version_string.split(':', 1)
    if '-' in version_string:
        version, release = version_string.rsplit('-', 1)
    else:
        version = version_string

    return (epoch, version, release)


def compare_versions(required_op, required_ver, provided_ver):
    """
    Compare versions using rpm.labelCompare.

    Args:
        required_op: Operator from requirement (e.g., ">=", "=", "<")
        required_ver: Required version string
        provided_ver: Provided version string

    Returns:
        bool: True if the requirement is satisfied
    """
    if not required_op or not required_ver:
        return True

    req_epoch, req_version, req_release = split_evr(required_ver)
    prov_epoch, prov_version, prov_release = split_evr(provided_ver)

    result = rpm.labelCompare(
        (req_epoch, req_version, req_release),
        (prov_epoch, prov_version, prov_release)
    )

    # result: -1 if required < provided, 0 if equal, 1 if required > provided
    if required_op in ('=', '=='):
        return result == 0
    elif required_op in ('>=', '=>'):
        return result <= 0  # required <= provided
    elif required_op == '>':
        return result < 0   # required < provided
    elif required_op in ('<=', '=<'):
        return result >= 0  # required >= provided
    elif required_op == '<':
        return result > 0   # required > provided
    else:
        return False


def check_dependencies(requires_json, system_provides_json, additional_provides_paths=None):
    """
    Checks requirements against a set of provides files.
    
    :param requires_json: Path to the specific requires.json being checked.
    :param system_provides_json: Path to the global system_provides.json.
    :param additional_provides_paths: List or string of paths to other provides.json files.
    """
    # 1. Load the requirements we need to satisfy
    with open(requires_json, 'r') as f:
        requires = json.load(f)

    # 2. Build a list of all provide sources
    search_paths = [system_provides_json]
    if isinstance(additional_provides_paths, str):
        search_paths.extend(additional_provides_paths.split())
    elif isinstance(additional_provides_paths, list):
        search_paths.extend(additional_provides_paths)

    # 3. Aggregate all capabilities (provides) into a searchable map
    provides_map = {}
    for path in search_paths:
        if path and os.path.exists(path):
            with open(path, 'r') as f:
                provides_list = json.load(f)
                for provide in provides_list:
                    name, _, version = parse_rpm_dependency(provide)
                    name_lower = name.lower()
                    if name_lower not in provides_map:
                        provides_map[name_lower] = []
                    provides_map[name_lower].append(version if version else None)

    # 4. Match requirements against the provides_map
    missing = []
    details = []

    for require in requires:
        req_name, req_op, req_ver = parse_rpm_dependency(require)

        # Skip internal RPM macros and absolute file paths
        if req_name.startswith('rpmlib(') or req_name.startswith('/'):
            continue

        satisfied = False
        matched_version = None
        req_name_lower = req_name.lower()

        if req_name_lower in provides_map:
            for prov_ver in provides_map[req_name_lower]:
                # Unversioned provides satisfy any version requirement
                if prov_ver is None:
                    satisfied = True
                    matched_version = "unversioned"
                    break
                # Versioned check
                elif compare_versions(req_op, req_ver, prov_ver):
                    satisfied = True
                    matched_version = prov_ver
                    break

        detail = {
            "requirement": require,
            "name": req_name,
            "satisfied": satisfied,
            "matched_version": matched_version
        }
        details.append(detail)

        if not satisfied:
            missing.append(require)

    return {
        "satisfied": len(missing) == 0,
        "missing": missing,
        "details": details
    }
    
if __name__ == "__main__":
    # Expecting: script.py <requires_json> <system_provides_json> <additional_provides_string>
    if len(sys.argv) < 3:
        print("Usage: check_dependencies.py <requires_json> <system_provides_json> [<additional_provides_list>]")
        sys.exit(1)

    requires_json = sys.argv[1]
    system_provides_json = sys.argv[2]
    # This captures the quoted string of paths as one argument
    additional_provides = sys.argv[3] if len(sys.argv) > 3 else None

    # Call the updated function
    result = check_dependencies(requires_json, system_provides_json, additional_provides)

    print(f'Result: {"SUCCESS" if result["satisfied"] else "FAILURE"}')
    print(f'All dependencies satisfied: {result["satisfied"]}')
    print(f'Total requirements: {len(result["details"])}')
    print(f'Missing: {len(result["missing"])}')

    if result['missing']:
        print('\nMissing Dependencies:')
        for req in result['missing']:
            print(f'  - {req}')

    print('\nDetailed analysis:')
    for detail in result['details']:
        status = '✓' if detail['satisfied'] else '✗'
        matched = f' (matched: {detail["matched_version"]})' if detail['satisfied'] and detail["matched_version"] else ''
        print(f'  {status} {detail["requirement"]}{matched}')

    sys.exit(0 if result['satisfied'] else 1)
