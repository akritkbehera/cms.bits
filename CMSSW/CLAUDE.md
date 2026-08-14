# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **CMSSW/** directory of the **cms.bits** repository - a virtual package provider for the bits build system that generates CMSSW Integration Build (IB) recipes on-demand. Instead of committing a static recipe file per IB, recipes are generated dynamically at build time from command-line arguments and a layered configuration.

Two virtual packages are produced:
- `cmssw_<queue>_<suffix>` - CMSSW IBs (e.g., `cmssw_14_2_x`), discovered from argv
- `cmssw-tools` - shared tool configuration (~130+ dependencies), always registered

Read `INIT.md` for a longer prose walkthrough (note: parts of its file map are stale — trust the code and this file where they disagree).

## Build Commands

Commands below assume the current directory is `CMSSW/`. `PYTHONPATH` must point at the `bits` checkout so `bits_helpers` and `config_loader` import. Local machine path: `/home/akbehera/Desktop/bitsorg/bits`.

### Test recipe generation without building
```bash
# CMSSW IB — args: cmssw <ib_name> <release_queue> <suffix> <date_time> <branch> [os] [flavor]
PYTHONPATH=/home/akbehera/Desktop/bitsorg/bits \
  python3 package.py cmssw CMSSW_14_2_X 14_2 _X 2026-06-19-2300 CMSSW_14_2_X el9

# Debug flavor variant (pulls in flavor/debug/vars.yaml)
PYTHONPATH=/home/akbehera/Desktop/bitsorg/bits \
  python3 package.py cmssw CMSSW_14_2_DEBUG_X 14_2 _DEBUG_X 2026-06-19-2300 CMSSW_14_2_X el9 debug

# cmssw-tools — args: cmssw-tools <release_queue> [os]
PYTHONPATH=/home/akbehera/Desktop/bitsorg/bits \
  python3 package.py cmssw-tools 14_2 el9
```
The generator prints the final YAML header, a `---` separator, then the bash body to stdout. Inspect the merged `variables:` block to confirm the layered config resolved as expected (e.g. `CMS_EIGEN_CXX_FLAGS: ...` proves the `os/el9` layer applied).

### Build packages with bits
```bash
bitsBuild build \
  --architecture el9_amd64_gcc14 \
  --force-unknown-architecture \
  --jobs 16 \
  --work-dir sw \
  -c /path/to/cms.bits \
  --docker --docker-image cmssw/el9:x86_64 \
  CMSSW_14_2_X
```

## Architecture

### Virtual Package Call Chain

```
bits build CMSSW_14_2_X
    ↓
packages.py:getPackages()
  - Scans sys.argv for ^CMSSW_(\d+_\d+)(_[A-Za-z]...)$  (case-insensitive)
  - Reads the OS token from $ARCHITECTURE (leading {os} of {os}_{arch}[_{compiler}])
  - Extracts build flavor from the IB suffix via _extract_flavor (_DEBUG_X → debug, etc.)
  - Registers cmssw_<queue>_<suffix>, embedding os/flavor into its `command`
  - Always registers cmssw-tools (not argv-driven — must resolve as a dependency)
    ↓
package.py (generator, one invocation per package)
  - Builds a ConfigLoader(pkg_dir)
  - loader.load_config(pkg_type, os, flavor, queue) → merged+resolved variables
  - Loads cmssw.yaml / cmssw-tools.yaml static spec
  - Reads build body (scram-project-build.sh or tool-conf-src.file from parent dir)
  - Applies <pkg>.file and <release_queue>.file overrides
  - Prints YAML header + "---" + bash body to stdout
    ↓
bits parses recipe, builds: cmssw-tools → CMSSW_14_2_X
```

### Layered Configuration (config_loader.py) — the core mechanism

Variables are assembled by merging YAML layers in this order (**later wins**):

```
legacy vars.yaml (fallback base) → base/ → os/{os}/ → flavor/{flavor}/ → queue/{queue}/ → <pkg>.file / <queue>.file overrides
```

Each layer is `CMSSW/<layer_type>/<value>/vars.yaml` (except `base/vars.yaml`). A layer's file is optional — if absent, that layer contributes nothing. Existing layers: `base/`, `os/el9/`, `flavor/debug/`. Add a new one by creating the directory + `vars.yaml`.

> **Note:** Arch-based configuration, vectorization, and microarch handling were **removed**. There is no `arch/` layer and no `-march`/vectorization plumbing on the CMSSW side. The frozen build body `../scram-project-build.sh` (outside `CMSSW/`, not editable here) still references `%(package_vectorization)s` and `%(scram_target_default)s`; both are kept defined as empty strings in `base/vars.yaml`/`vars.yaml` so BITS' **strict** recipe substitution does not fail. Do not delete those two keys.

**Merge semantics (`_deep_merge`), important and non-obvious:**
- Dicts merge recursively; **lists are replaced, not concatenated**
- A key prefixed `remove_` **deletes** the target key (`remove_foo:` drops `foo`)
- A `null`/`None` value **deletes** the key
- `%(varname)s` placeholders are resolved after merging, in up to 10 passes, so variables may reference other variables

A layer file with bare key-value pairs (no `variables:`, `requires:`, `sources:`, etc.) is auto-wrapped as `{variables: ...}`.

### Key Files

| File | Purpose |
|------|---------|
| `packages.py` | Registration — discovers IBs from argv; parses os/flavor context |
| `package.py` | Generator — assembles and prints the recipe to stdout |
| `config_loader.py` | `ConfigLoader`: layered YAML merge + variable resolution |
| `cmssw.yaml` | Static spec (requires/sources/build_requires) for CMSSW IBs |
| `cmssw-tools.yaml` | Static spec for cmssw-tools (~130 deps + tools-repo source/tag) |
| `base/vars.yaml` | Core default variables |
| `os/{os}/vars.yaml` | OS-specific flags (e.g. el9 Eigen/LTO flags) |
| `flavor/{flavor}/vars.yaml` | Build-flavor overrides (e.g. debug: `-O0 -g3`) |
| `vars.yaml` | **Legacy** fallback base — superseded by `base/` + layers |
| `vars.conf` | **Legacy**, do not edit |
| `../scram-project-build.sh` | Build body template for CMSSW IBs (parent dir) |
| `../tool-conf-src.file` | Build body template for cmssw-tools (parent dir) |
| `INIT.md` | Prose overview (partially stale) |

Note: `package.py` reads `../scram-project-build.sh` for the CMSSW body (INIT.md's claim that `.file` is the body and `.sh` is legacy is out of date). The CMSSW body is also prefixed at generation time with `source $WORK_DIR/cmsset_default.sh`.

### Override Files

`<pkg>.file` and `<release_queue>.file` override variables and/or prepend to the build body. Format:
```yaml
variables:
  configtag: V10-00-01
  gpu_types: cuda
---
# Optional bash prepended to the default body
export MY_EXTRA_VAR=1
```
Override `variables:` **merge** with (not replace) the layered variables; other spec keys replace. Applied in `package.py` via `apply_override`. `cmssw-tools.file` currently pins the tools-repo `tag`/`source`. A `<queue>.file` (e.g. `14_2.file`) is applied last, after all layers and the `<pkg>.file`.

## Conventions

**DO:**
- Put build-wide defaults in `base/vars.yaml`; scope specifics to the right `os/`, `flavor/`, or `queue/` layer
- Edit `cmssw.yaml` / `cmssw-tools.yaml` for requires/sources changes
- Create `CMSSW/<release_queue>.file` for queue-specific overrides
- Edit `../scram-project-build.sh` / `../tool-conf-src.file` for build-script changes
- Verify changes by running the generator and inspecting the merged `variables:` block

**DO NOT:**
- Add static `CMSSW_*.sh` files — recipes are generated dynamically
- Edit `vars.conf` (legacy); prefer `base/vars.yaml` over the legacy `vars.yaml`
- Change `PY_` variable prefixes to `PY3_` — breaks tool XML generation
- Hard-code release queues — they are discovered from argv

**KEY INVARIANT:** Virtual package keys must be LOWERCASE — bits lowercases all package names before lookup (`packages.py` registers `pkg_key = ib_name.lower()`).
