"""Shared vectorization configuration for package and SCRAM generators."""
import re
from os.path import join
from bits_helpers.utilities import yamlLoad


def load_config(config_dir):
    with open(join(config_dir, 'vectorization', 'config.yaml')) as f:
        config = yamlLoad(f.read())
    # Discovery runs before BITS resolves its defaults chain. Expand config values
    # using the variables declared in this repository's defaults-release recipe.
    with open(join(config_dir, 'defaults-release.sh')) as f:
      defaults = yamlLoad(f.read().split('---', 1)[0])
    variables = defaults.get('variables', {})
    def expand(value):
      if isinstance(value, str):
        return re.sub(r'%\(([^)]+)\)s', lambda m: str(variables[m.group(1)]), value)
      if isinstance(value, list):
        return [expand(item) for item in value]
      if isinstance(value, dict):
        return {key: expand(item) for key, item in value.items()}
      return value
    config = expand(config)
    config.setdefault('build_targets', config['supported_targets'])
    config['build_targets'] = list(dict.fromkeys(config['build_targets']))
    if not set(config['build_targets']).issubset(config['supported_targets']):
        raise ValueError('build_targets must be selected from supported_targets')
    config.setdefault('enabled_packages', config['supported_packages'])
    supported = {name.lower() for name in config['supported_packages']}
    if any(name.lower() not in supported for name in config['enabled_packages']):
        raise ValueError('enabled_packages must be selected from supported_packages')
    return config
