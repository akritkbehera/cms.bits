def getPackages(virtual_packages, configDir, *args):
  import os, re, sys
  from os.path import dirname, join
  from datetime import datetime, timezone

  pkg_dir = dirname(__file__)

  if os.environ.get("IB_DATE_TIME"):
    date_time = os.environ["IB_DATE_TIME"]
  else:
    date    = os.environ.get("IB_DATE", datetime.now(timezone.utc).strftime("%Y-%m-%d"))
    ib_time = os.environ.get("IB_TIME", "2300")
    date_time = "%s-%s" % (date, ib_time)

  pattern = re.compile(r'^(CMSSW_(\d+_\d+)(_[A-Za-z][A-Za-z0-9_]*))$', re.IGNORECASE)

  found_queues = []
  for arg in sys.argv:
    m = pattern.match(arg)
    if not m:
      continue
    ib_name       = m.group(1).upper()
    release_queue = m.group(2)
    suffix        = m.group(3).upper()
    pkg_key       = ib_name.lower()
    if release_queue not in found_queues:
      found_queues.append(release_queue)
    if pkg_key in virtual_packages:
      continue
    branch       = os.environ.get("CMSSW_BRANCH", "CMSSW_%s_X" % release_queue)
    full_version = "%s_%s" % (ib_name, date_time)

    # Extract flavor from suffix
    flavor = _extract_flavor(suffix)

    virtual_packages[pkg_key] = {
      "version": full_version,
      "pkgdir":  configDir,
      "url":     ib_name + ".sh",
      "command": 'PYTHONPATH=%s %s/package.py "cmssw" "%s" "%s" "%s" "%s" "%s" "%s"' % (
        dirname(sys.argv[0]), pkg_dir,
        ib_name, release_queue, suffix, date_time, branch,
        flavor or '',
      ),
    }

  # Determine release_queue: prefer argv match, then env var, then empty string
  release_queue = found_queues[0] if found_queues else os.environ.get("CMSSW_QUEUE", "")

  # Always register cmssw-tools so it is resolvable as a dependency of any CMSSW IB.
  # Unlike CMSSW_* IBs it is not driven by argv — it must always be available.
  if "cmssw-tools" not in virtual_packages:
    version = "vCMS_%s" % release_queue if release_queue else "vCMS"
    virtual_packages["cmssw-tools"] = {
      "version": version,
      "pkgdir":  configDir,
      "url":     "cmssw-tools.sh",
      "command": 'PYTHONPATH=%s %s/package.py "cmssw-tools" "%s"' % (
        dirname(sys.argv[0]), pkg_dir, release_queue,
      ),
    }


def _extract_flavor(suffix):
  """
  Extract build flavor from IB suffix.

  Examples:
      '_X' -> None (standard)
      '_DEBUG_X' -> 'debug'
      '_ASAN_X' -> 'asan'
      '_UBSAN_X' -> 'ubsan'
      '_CLANG_X' -> 'clang'

  Args:
      suffix: IB suffix (e.g., '_DEBUG_X', '_X')

  Returns:
      Flavor string (lowercase) or None for standard builds
  """
  if not suffix:
    return None

  # Normalize to uppercase
  suffix = suffix.upper()

  # Remove leading underscore
  if suffix.startswith('_'):
    suffix = suffix[1:]

  # Standard build suffixes (no flavor)
  if suffix in ('X', 'DEVEL', 'PATCH'):
    return None

  # Remove trailing _X, _DEVEL, _PATCH markers
  for marker in ('_X', '_DEVEL', '_PATCH'):
    if suffix.endswith(marker):
      suffix = suffix[:-len(marker)]
      break

  # Empty after stripping means standard build
  if not suffix:
    return None

  # Common flavors
  known_flavors = {
    'DEBUG': 'debug',
    'ASAN': 'asan',
    'UBSAN': 'ubsan',
    'TSAN': 'tsan',
    'CLANG': 'clang',
    'CUDA': 'cuda',
    'ROCM': 'rocm',
    'PGO': 'pgo',
  }

  # Check for known flavors in the suffix
  for known, flavor in known_flavors.items():
    if known in suffix:
      return flavor

  # Return the suffix as-is (lowercased) for unknown flavors
  return suffix.lower() if suffix else None
