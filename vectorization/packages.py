def getPackages(virtual_packages, configDir, *args):
  import re
  import sys
  from os.path import dirname, join, exists

  pkg_dir = dirname(__file__)
  targets_file = join(pkg_dir, 'targets.txt')
  if not exists(targets_file):
    return

  VALID_TARGETS = {
    "nehalem":        "-march=nehalem",
    "sandybridge":    "-march=sandybridge",
    "haswell":        "-march=haswell",
    "skylake-avx512": "-march=skylake-avx512",
    "x86-64-v2":     "-march=x86-64-v2",
    "x86-64-v3":     "-march=x86-64-v3",
    "x86-64-v4":     "-march=x86-64-v4",
  }

  VECTORIZABLE_PACKAGES = ["fastjet", "openblas", "rivet", "gbl", "lwtnn", "opencv", "pytorch"]

  enabled_targets = []
  with open(targets_file) as f:
    for line in f:
      line = line.strip()
      if not line or line.startswith('#'):
        continue
      if line in VALID_TARGETS:
        enabled_targets.append(line)

  if not enabled_targets:
    return

  for pkg in VECTORIZABLE_PACKAGES:
    base_recipe = join(configDir, pkg + '.sh')
    if not exists(base_recipe):
      continue
    with open(base_recipe) as f:
      content = f.read()
    m = re.search(r'^version:\s*["\']?([^"\'\n]+)["\']?', content, re.MULTILINE)
    if not m:
      continue
    version = m.group(1).strip()

    for target in enabled_targets:
      march_flag = VALID_TARGETS[target]
      vpkg_name = '%s_%s' % (pkg, target)
      if vpkg_name in virtual_packages:
        continue
      virtual_packages[vpkg_name] = {
        "version": version,
        "pkgdir": configDir,
        "url": pkg + '.sh',
        "command": 'PYTHONPATH=%s %s/package.py "%s" "%s" "%s" "%s"' % (
          dirname(sys.argv[0]), pkg_dir,
          base_recipe, vpkg_name, target, march_flag,
        ),
      }
