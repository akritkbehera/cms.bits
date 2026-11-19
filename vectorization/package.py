#!/usr/bin/env python3
# argv: package.py <base_recipe> <vpkg_name> <target_name> <march_flag>
import sys
import re
from os.path import dirname
from bits_helpers.utilities import yamlLoad, yamlDump
from vectorization_config import load_config

base_recipe = sys.argv[1]   # e.g. /path/to/cms.bits/fastjet.sh
vpkg_name   = sys.argv[2]   # e.g. fastjet-x86-64-v2
target_name = sys.argv[3]   # e.g. haswell
march_flag  = sys.argv[4]   # e.g. -march=haswell

with open(base_recipe) as f:
  content = f.read()

header, body = content.split('---', 1)

spec = yamlLoad(header.strip())
spec['package'] = vpkg_name

variables = spec.get('variables', {})
variables['override_microarch_name'] = target_name
spec['variables'] = variables

supported = {name.lower() for name in load_config(dirname(base_recipe))['enabled_packages']}
aliases = []
for key in ('requires', 'build_requires', 'untracked_requires'):
  for index, dependency in enumerate(spec.get(key, [])):
    match = re.match(r'^([A-Za-z0-9_-]+)(.*)$', dependency)
    if not match or match.group(1).lower() not in supported:
      continue
    original, condition = match.groups()
    variant = original.lower() + '_' + target_name
    spec[key][index] = variant + condition
    base_id = re.sub(r'[^A-Za-z0-9_]', '_', original).upper()
    variant_id = re.sub(r'[^A-Za-z0-9_]', '_', variant).upper()
    for suffix in ('ROOT', 'VERSION', 'REVISION', 'HASH', 'COMMIT', 'INCLUDE_DIR'):
      source = variant_id + '_' + suffix
      destination = base_id + '_' + suffix
      aliases.append('if [ "${%s+x}" ]; then export %s="${%s}"; fi' % (source, destination, source))

print(yamlDump(spec).strip())
print('---')
print('\n'.join(aliases))
print(body.strip())
