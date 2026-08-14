#!/usr/bin/env python3
# argv: package.py <base_recipe> <vpkg_name> <target_name> <march_flag>
import re
import sys
from bits_helpers.utilities import yamlLoad, yamlDump

base_recipe = sys.argv[1]   # e.g. /path/to/cms.bits/fastjet.sh
vpkg_name   = sys.argv[2]   # e.g. fastjet_haswell
target_name = sys.argv[3]   # e.g. haswell
march_flag  = sys.argv[4]   # e.g. -march=haswell

with open(base_recipe) as f:
  content = f.read()

header, body = content.split('---', 1)

spec = yamlLoad(header.strip())
spec['package'] = vpkg_name

variables = spec.get('variables', {})
variables['selected_microarch'] = march_flag
spec['variables'] = variables

# Replace any hardcoded -march=<target> in the shell body with the new target
body = re.sub(r'-march=[a-z0-9_-]+', march_flag, body)

print(yamlDump(spec).strip())
print('---')
print('export selected_microarch="%s"' % march_flag)
print(body.strip())
