def getPackages(virtual_packages, configDir, *args):
  import re
  import sys
  import shlex
  from os.path import dirname, join, exists
  from bits_helpers.utilities import yamlLoad
  from vectorization_config import load_config

  pkg_dir = dirname(__file__)
  config_file = join(pkg_dir, 'config.yaml')
  if not exists(config_file):
    return
  with open(config_file) as f:
    config = yamlLoad(f.read())
  config = load_config(configDir)

  valid_targets = {name: '-march=' + name for name in config.get('supported_targets', [])}
  default_target = config.get('default_target', [])
  default_target = default_target[0] if isinstance(default_target, list) else default_target
  if default_target not in valid_targets:
    raise ValueError('vectorization default_target must be a supported target')
  def command(script, *arguments):
    return 'PYTHONPATH=%s %s %s %s' % (
      shlex.quote(dirname(sys.argv[0])), shlex.quote(sys.executable),
      shlex.quote(join(pkg_dir, script)),
      ' '.join(shlex.quote(str(arg)) for arg in arguments))
  enabled = {name.lower() for name in config['enabled_packages']}
  for pkg in config['supported_packages']:
    recipe_name = pkg.lower()
    base_recipe = join(configDir, recipe_name + '.sh')
    if not exists(base_recipe):
      continue
    with open(base_recipe) as f:
      content = f.read()
    m = re.search(r'^version:\s*["\']?([^"\'\n]+)', content, re.MULTILINE)
    if not m:
      continue
    version = m.group(1).strip()
    for target, march_flag in valid_targets.items():
      name = '%s-%s' % (recipe_name, target)
      for alias in (name, '%s_%s' % (recipe_name, target)):
        if alias not in virtual_packages:
          virtual_packages[alias] = {
            'version': version, 'pkgdir': configDir, 'url': recipe_name + '.sh',
            'command': command('package.py', base_recipe, alias, target, march_flag),
          }
    if recipe_name not in enabled:
      continue
    wrapper = '%s_%s' % (recipe_name, default_target)
    virtual_packages.setdefault(recipe_name, {
      'version': version, 'pkgdir': configDir, 'url': recipe_name + '.sh',
      'command': command('wrapper.py', base_recipe, recipe_name, wrapper),
    })
