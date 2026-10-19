#!/usr/bin/env python3
"""Validate a port using bits' real parser and hash-input expansion, without builds.

Run with bits_helpers on PYTHONPATH. An optional argument selects a cmsdist
checkout for pin and data-tag comparisons.
"""
from copy import deepcopy
import os
from pathlib import Path
import re
import subprocess
import sys
import yaml

from bits_helpers.recipe import parseRecipe
from bits_helpers.build import prepare_hash_inputs

ROOT = Path(__file__).resolve().parents[1]
DEFAULTS = yaml.safe_load((ROOT / 'defaults-release.sh').read_text().split('---', 1)[0])['variables']


class Reader:
    def __init__(self, name, text=None):
        self.url = str(ROOT / name)
        self.text = text

    def __call__(self):
        return self.text if self.text is not None else Path(self.url).read_text()


errors = []
specs = {}
checks = 0


def validate(name, text=None):
    global checks
    error, spec, body = parseRecipe(Reader(name, text))
    if error:
        errors.append((name, error))
        return
    specs[spec['package'].lower()] = deepcopy(spec)
    spec['recipe'] = body
    # This offline check validates expansion without querying Git remotes.
    spec.setdefault('scm_refs', {})
    try:
        prepare_hash_inputs(spec, {'Python': {'version': '3.12.11'}}, ['release'],
                            DEFAULTS, str(ROOT))
        result = subprocess.run(['bash', '-n'], input=spec['recipe'], text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if result.returncode:
            errors.append((name, result.stderr))
        for patch in spec.get('patches', []):
            if not (ROOT / 'patches' / patch).is_file() and not Path(patch).is_file():
                errors.append((name, 'Missing patch: ' + patch))
    except (Exception, SystemExit) as exc:
        errors.append((name, str(exc)))
    checks += 1


changed = subprocess.check_output(['git', 'diff', '--name-only'], cwd=ROOT, text=True).splitlines()
changed += subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard'], cwd=ROOT, text=True).splitlines()
# coral-tools also consumes tool-conf-src.file, without CMSSW's recipe variables.
changed.append('coral-tools.sh')
for name in dict.fromkeys(changed):
    if name.endswith('.sh') and re.search(r'^---\s*$', (ROOT / name).read_text(), re.M):
        validate(name)

# Check the generated recipe for every Python pin, including the backend variants.
python_count = 0
for line in (ROOT / 'pypi/requirements.txt').read_text().splitlines():
    if line.startswith('#'):
        continue
    match = re.match(r'([^= ;]+)==([^; #]+)', line)
    if not match:
        continue
    package, version = match.groups()
    result = subprocess.run([sys.executable, str(ROOT / 'pypi/package.py'),
                             'py-' + package, version, 'py3'],
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode:
        errors.append((package, result.stderr))
        continue
    validate('py-' + package + '.sh', result.stdout)
    python_count += 1

result = subprocess.run([sys.executable, str(ROOT / 'CMSSW/package.py'),
                         'cmssw-tools', '20_1', 'el9'],
                        text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
if result.returncode:
    errors.append(('cmssw-tools', result.stderr))
else:
    validate('cmssw-tools.sh', result.stdout)

# Check newly introduced dependencies against all the existing recipe names.
known = set(specs)
for path in ROOT.glob('*.sh'):
    try:
        header = yaml.safe_load(re.split(r'^---\s*$', path.read_text(), maxsplit=1, flags=re.M)[0])
        if isinstance(header, dict) and 'package' in header:
            known.add(str(header['package']).lower())
    except yaml.YAMLError:
        pass
known.update('data-' + m.group(1).lower() for m in re.finditer(
    r'^([^#\[\s=]+)=', (ROOT / 'data/packages.txt').read_text(), re.M))
missing = {}
for name, spec in specs.items():
    for dep in spec.get('requires', []) + spec.get('build_requires', []):
        if dep.lower() not in known:
            missing.setdefault(dep, []).append(name)

if len(sys.argv) > 1:
    upstream = Path(sys.argv[1])
    def pins(path):
        values = {}
        for line in path.read_text().splitlines():
            m = re.match(r'([^#= ;]+)==([^; #]+)', line)
            if m:
                values.setdefault(re.sub(r'[-_.]+', '-', m[1]).lower(), m[2])
        return values
    ours = pins(ROOT / 'pypi/requirements.txt')
    theirs = pins(upstream / 'pip/requirements.txt')
    mismatches = {name: [ours.get(name), ver] for name, ver in theirs.items() if ours.get(name) != ver}
    print('Upstream Python pin mismatches (first variant = EL9):', mismatches)
    print('Preserved bits-only Python packages:', sorted(ours.keys() - theirs.keys()))
    if mismatches:
        errors.append(('requirements', str(mismatches)))

print('Validated recipe bodies:', checks, '(including', python_count, 'Python packages)')
print('Unresolved dependency names:', missing)
print('Errors:', errors)
# Existing non-port dependency omissions are reported separately for review.
sys.exit(bool(errors))
