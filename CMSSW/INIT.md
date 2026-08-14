#!/usr/bin/env bash
# =============================================================================
# INIT.sh — Context file for AI agents and human contributors
# Describes the cms.bits/CMSSW/ virtual package system and how everything
# connects. Read this before editing any file in this directory.
# =============================================================================
#
# WHAT THIS DIRECTORY DOES
# ------------------------
# CMSSW/ is a virtual package provider for the bits build system. It generates
# CMSSW Integration Build (IB) recipes on-demand at build time rather than
# keeping a static .sh recipe per IB. This means you never need to commit a new
# file when a new IB comes out — bits discovers it from the command line.
#
# There are two virtual packages produced here:
#   1. cmssw_<queue>_<suffix>  — the actual CMSSW IB (e.g. cmssw_14_2_x)
#   2. cmssw-tools             — the shared tool configuration package that
#                                every IB depends on
#
# =============================================================================
# FILE MAP
# =============================================================================
#
# CMSSW/
# ├── INIT.sh            ← you are here. Context file for AI agents.
# ├── packages.py        ← REGISTRATION: scans sys.argv at startup, tells bits
# │                         which virtual packages exist and how to generate them.
# ├── package.py         ← GENERATOR: called by bits per-package, prints a
# │                         YAML+bash recipe to stdout.
# ├── cmssw.yaml         ← Static spec fields for CMSSW IBs (requires, sources,
# │                         build_requires). Dynamic fields (package, version,
# │                         variables) are set by package.py at generation time.
# ├── cmssw-tools.yaml   ← Static spec for cmssw-tools: the full requires list
# │                         (~130 packages) plus source/tag for the tools repo.
# ├── vars.yaml          ← Shared variables injected into every recipe via
# │                         %(varname)s substitution. Covers compiler flags,
# │                         build targets, GPU config, PGO, etc.
# ├── vars.conf          ← LEGACY. Superseded by vars.yaml. Do not edit.
# └── <release_queue>.file  ← Optional per-queue override. Created manually
#                             when a specific queue needs different variables or
#                             a different build body (e.g. 14_2.file).
#
# cms.bits/  (parent directory)
# ├── scram-project-build.file  ← Build body for CMSSW IBs. Pure bash template
# │                                with %(varname)s placeholders. Inlined by
# │                                package.py — never executed directly.
# ├── tool-conf-src.file        ← Build body for cmssw-tools. Same pattern.
# ├── scram-project-build.sh    ← Build body actually read by package.py for
# │                                CMSSW IBs (the .file above is a stale copy).
# └── vectorization/            ← LEGACY / independent. Not wired into cmssw-tools
#                                 from CMSSW/ (arch/vectorization support removed).
#
# =============================================================================
# HOW BITS CALLS THIS CODE  (the call chain)
# =============================================================================
#
#  $ bits build CMSSW_14_2_X
#         │
#         ▼
#  bits_helpers/utilities.py : getGeneratedPackages(configDir)
#    └── globs for cms.bits/*/packages.py
#    └── imports CMSSW/packages.py
#    └── calls packages.py:getPackages(dir_pkgs, configDir)
#           │  scans sys.argv for pattern ^CMSSW_(\d+_\d+)(_[A-Za-z]...)$
#           │  registers "cmssw_14_2_x" → {version, command, ...}
#           └─ always registers "cmssw-tools" → {version, command, ...}
#         │
#         ▼
#  utilities.py : resolveFilename("cmssw_14_2_x")
#    └── virtual packages checked FIRST, before filesystem .sh lookup
#    └── found → returns "generate:cmssw_14_2_x@<version>"
#         │
#         ▼
#  utilities.py : GeneratedPackage.__call__()
#    └── runs: PYTHONPATH=<bits> CMSSW/package.py "cmssw" "CMSSW_14_2_X" ...
#    └── captures stdout → recipe text
#         │
#         ▼
#  package.py  (the generator)
#    └── loads cmssw.yaml          (static spec)
#    └── loads vars.yaml           (shared variables)
#    └── reads scram-project-build.file  (build body)
#    └── applies cmssw.file override if present
#    └── prints YAML header + "---" + bash body to stdout
#         │
#         ▼
#  bits parses recipe, resolves dependencies, builds in topological order
#    cmssw-tools  →  CMSSW_14_2_X
#
# =============================================================================
# RECIPE FORMAT (what package.py prints)
# =============================================================================
#
#  package: CMSSW_14_2_X
#  version: CMSSW_14_2_X_2026-06-19-2300
#  requires:
#   - cmssw-tool-conf
#  sources:
#   - git+https://...cmssw-config...
#   - git+https://...cmssw...
#  variables:
#    configtag: V09-09-03
#    branch: CMSSW_14_2_X
#    ... (all of vars.yaml)
#  ---
#  source $WORK_DIR/cmsset_default.sh
#  <contents of scram-project-build.file with %(varname)s already live>
#
# bits substitutes %(varname)s before executing the bash body.
#
# =============================================================================
# OVERRIDE FILES  (<pkg>.file)
# =============================================================================
#
# Drop a file named CMSSW/<pkg>.file to override variables or prepend a custom
# build body for that package. Format:
#
#   # YAML header — merged into spec (variables are deep-merged, not replaced)
#   variables:
#     configtag: V10-00-01
#     gpu_types: cuda
#   ---
#   # Optional bash snippet — PREPENDED in front of the default body.
#   # Omit the --- section entirely to only change variables.
#   export MY_EXTRA_VAR=1
#
# Supported override files:
#   CMSSW/cmssw.file        — applies to all CMSSW IBs
#   CMSSW/cmssw-tools.file  — applies to cmssw-tools
#   CMSSW/14_2.file         — applies only to the 14_2 release queue
#                              (currently not wired up; add to packages.py if needed)
#
# =============================================================================
# ARCH / VECTORIZATION / MICROARCH — REMOVED
# =============================================================================
#
# Arch-based layered config, vectorization, and microarch handling have been
# removed from this generator. There is no arch/ config layer, no -march /
# vectorization plumbing, and packages.py no longer parses an arch from
# $ARCHITECTURE (only the leading OS token, for the os/ layer).
#
# Two keys — package_vectorization and scram_target_default — are still kept
# (empty) in base/vars.yaml and vars.yaml ONLY because the frozen build body
# ../scram-project-build.sh references them via %(...)s and BITS substitutes
# recipe bodies in STRICT mode (an unknown %(x)s is fatal). Empty = disabled.
# Do not delete those two keys unless that build body is also changed.
#
# The parent cms.bits/vectorization/ generator (fastjet_<target>, etc.) is
# independent of this directory and is not wired into cmssw-tools here.
#
# =============================================================================
# VARIABLES REFERENCE  (vars.yaml keys)
# =============================================================================
#
# Key variables an AI agent is likely to need:
#
#   configtag          CMSSW config tag (e.g. V09-09-03). Determines which
#                      cmssw-config commit is fetched as SOURCE0.
#   branch             Git branch for cmssw.git checkout. Set per-IB by
#                      packages.py from CMSSW_BRANCH env or "CMSSW_<queue>_X".
#   buildtarget        SCRAM build target passed to `scram b`. Default: release-build.
#   scram_compiler     Compiler tool name as SCRAM knows it. Default: gcc.
#   enable_biglib      "1" enables biglib (combined .so). Default: "1".
#   subpackageDebug    "yes" splits debug symbols into .debug files. Default: "yes".
#   gpu_types          Space-separated GPU vendor list (e.g. "cuda rocm").
#   pgo_generate       Non-empty = PGO instrumentation build.
#   package_vectorization  Kept empty for build-body compatibility only
#                          (see ARCH / VECTORIZATION / MICROARCH — REMOVED).
#   scram_target_default   Kept empty for build-body compatibility only.
#
# =============================================================================
# CONVENTIONS FOR AI AGENTS
# =============================================================================
#
# DO:
#   - Edit vars.yaml to change build-wide defaults (compiler flags, targets, etc.)
#   - Edit cmssw.yaml / cmssw-tools.yaml to change requires lists or sources.
#   - Create CMSSW/<release_queue>.file to override a specific queue without
#     touching the defaults.
#   - Edit packages.py only to change how IBs are discovered (pattern, env vars,
#     date derivation) — not to add static package data.
#   - Edit package.py only to change recipe generation logic.
#   - Edit scram-project-build.file / tool-conf-src.file for build script changes.
#
# DO NOT:
#   - Add static CMSSW_*.sh files — the whole point is they are generated.
#   - Change PY_ variable prefixes to PY3_ — this breaks tool XML generation.
#   - Modify vars.conf — it is a legacy file, vars.yaml is authoritative.
#   - Add runtime calls to resolve_meta.py inside recipe bodies — inline the
#     file content in package.py instead (the .file pattern).
#   - Hard-code release queues anywhere — they are discovered from argv.
#
# KEY INVARIANT:
#   virtual_packages keys must be LOWERCASE (bits lowercases all package names
#   before lookup). Uppercase is only used inside the recipe content itself.
#
# =============================================================================
# HOW TO TEST A RECIPE WITHOUT BUILDING
# =============================================================================
#
#  PYTHONPATH=/path/to/bits/bits \
#    python3 cms.bits/CMSSW/package.py cmssw CMSSW_14_2_X 14_2 _X 2026-06-19-2300 CMSSW_14_2_X
#
#  PYTHONPATH=/path/to/bits/bits \
#    python3 cms.bits/CMSSW/package.py cmssw-tools 14_2
#
# Both commands print the full recipe to stdout — YAML header + bash body.
# Inspect the output to verify variable substitution and requires list.
#
# =============================================================================

# This script is intentionally a no-op when sourced or executed.
: # no-op
