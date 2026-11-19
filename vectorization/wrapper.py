#!/usr/bin/env python3
import sys
from pathlib import Path
from bits_helpers.utilities import yamlLoad, yamlDump
from vectorization_config import load_config

base_recipe, package_name, target_package = sys.argv[1:4]
with open(base_recipe) as f:
  spec = yamlLoad(f.read().split('---', 1)[0].strip())
wrapper = type(spec)()
wrapper['package'] = spec['package']
wrapper['version'] = spec['version']
# Untracked consumers record this install path in their init.sh.
wrapper['force_revision'] = ''
wrapper['hook'] = {'POST_INSTALL': 'check_dependencies,generate_module,vectorization-wrapper'}
config = load_config(str(Path(base_recipe).parent))
wrapper['requires'] = [package_name.lower() + '_' + target for target in config['build_targets']]
if target_package not in wrapper['requires']:
  wrapper['requires'].append(target_package)
target = target_package[len(package_name) + 1:]
wrapper['variables'] = {'wrapper_target_id': target_package.upper().replace('-', '_')}
wrapper['hook_params'] = {'VECTOR_WRAPPER_TARGET': target}
print(yamlDump(wrapper).strip())
print('---')
print(Path(__file__).with_name('wrapper.file').read_text(), end='')
