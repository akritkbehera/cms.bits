#!/usr/bin/env python3
import sys
from pathlib import Path
from bits_helpers.utilities import pkg_to_shell_id, yamlLoad, yamlDump
from vectorization_config import load_config

base_recipe, package_name, target_package = sys.argv[1:4]
with open(base_recipe) as f:
  spec = yamlLoad(f.read().split('---', 1)[0].strip())
wrapper = type(spec)()
wrapper['package'] = spec['package']
wrapper['version'] = spec['version']
# Untracked consumers record this install path in their init.sh.
wrapper['force_revision'] = ''
wrapper['hook'] = {'POST_INSTALL': 'check_dependencies,generate_module'}
config = load_config(str(Path(base_recipe).parent))
wrapper['requires'] = [package_name.lower() + '_' + target for target in config['build_targets']]
if target_package not in wrapper['requires']:
  wrapper['requires'].append(target_package)
wrapper['variables'] = {
  'wrapper_package': wrapper['package'],
  'wrapper_id': pkg_to_shell_id(wrapper['package']),
  'wrapper_target_id': pkg_to_shell_id(target_package),
}
print(yamlDump(wrapper).strip())
print('---')
print(Path(__file__).with_name('wrapper.file').read_text(), end='')
