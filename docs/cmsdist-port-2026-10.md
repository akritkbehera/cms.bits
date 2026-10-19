# CMSDIST port: October 2026

Source snapshot: cmsdist `5b180f4f5` on `IB/CMSSW_20_1_X/master`.
Previous recorded port baseline: `fa77cb2b2`.
Destination baseline: cms.bits `05217a9` on `IB/CMSSW_20_1_X/gcc14`.
The accompanying JSON ledger accounts for all 92 changed upstream files.

## Recipe and dependency updates

- CUDA 13.4.2 / NVIDIA driver 615.71.09: use the new toolkit runfile names
  and separate redistributable driver archives on x86_64 and aarch64. Package
  the added GPU compiler, NVVM70 and tile IR libraries, retain the runtime
  static archives, install driver-backed stub libraries, and fix nvcc.profile.
  Retain the bits headless-installer workaround. Drop split-compile and enable
  make-integrated nvcc parallelism on x86_64 only, matching cmsdist.
- ROOT 6.40.05 at the upstream commit, with curl and Python TMVA support.
- ONNX Runtime 1.30.0 with all six upstream patches, the CUDA plugin provider,
  MIGraphX provider and Python packaging, protobuf-lite, bundled flatbuffers,
  explicit telemetry/FP4 settings, and the upstream compiler workarounds.
- Add MIGraphX 7.14 and its five patches, hipfile, hipcc-parallel 260921.2,
  NNVtx 1.0.1, and Sherpa 3.0.5 with versioned libraries. Connect these to the
  actual generated cmssw-tools dependency configuration.
- SCRAM V3_00_96, TBB v2023.1.0, GDB 17.2, ISA-L v2.32.1, NASM 3.02,
  L1TSC4NGJetModel 2.1.0, and the updated igprof/cms-git-tools commits.
  cms-git-tools keeps an integer date version for its existing bits installation
  protocol; the upstream `.0` version suffix is not needed there.
- Port the Catch2, Dyninst/TBB, Eigen and UCX changes, OpenLoops headers and
  process metadata, and the current Eigen compile flags.
- Update 139 Python pins in `pypi/requirements.txt` from cmsdist's `pip` tree.
  Preserve six bits-only packages and the EL9 cryptography 50.0.1 selection;
  upstream's alternate cryptography pin is for EL8, which this configuration
  does not select. Synchronize the existing derived requirements list too.
- Port the changed Python build dependencies, pysqlite3 patch, removal of the
  obsolete threadpoolctl patch, pyg-lib library location, and suffix all Torch
  backend executables. Use bits includes for the modified shared build fragments
  so changes enter the consuming recipe hashes.
- All current cmsdist data package names and versions match `data/packages.txt`.
  Add IOMC-Input to the data meta-packages.
- Update the generated CMSSW configuration tag to V09-10-12. Existing older
  standalone CMSSW release examples retain their own release selection.

## TensorFlow cache and build packages

Both `tensorflow-sources-cache.sh` and `tensorflow-sources.sh` include the single
`tensorflow-build.file`. They select the mode with the Bash statement
`fetch_externals=yes` or `fetch_externals=no` before the include. Source revision,
patches, configure logic and build flags are shared. Both currently use TF 2.21.0;
there is a test requiring their source metadata to stay synchronized.

1. The cache package runs `bazel fetch`, without compiling TensorFlow, and copies
   Bazel's repository cache into `INSTALLROOT/repository_cache`. It also installs
   a relative-path `SHA256SUMS` manifest. This is an ordinary bits package artifact:
   bits can publish it through the configured store, without a separate upload
   implementation or CMS RPM source-cache service.
2. The build package has a build dependency on the cache package. It verifies
   the manifest and copies the cache into its own writable build area. It passes
   `--repository_disable_download` to Bazel, builds numpy and the TensorFlow wheel,
   and installs the wheel and XLA FFT archives. The installed cache stays unchanged.

Use the Python dependency's exported version instead of hard-coded 3.12 values.
Cap the TF compiler standard at C++20 as upstream does. Preserve the previously
ported TF 2.21 fixes and locate the wheel/runtime outputs through `bazel-bin`.
Fail explicitly on an empty cache, checksum failure, absent/ambiguous wheel, or
absent/ambiguous FFT archive.

Example builds, using an existing bits setup and its usual defaults/store options:

```bash
bits build -c /path/to/cms.bits tensorflow-sources-cache
bits build -c /path/to/cms.bits tensorflow-sources
```

The second command resolves the cache dependency automatically. These commands
are build examples; no full TensorFlow rebuild or remote publication was performed
while preparing this port.

## SCRAM tool declarations

`patches/scram-tools-cmsdist-sync.patch` applies to the existing downloadable
scram-tools.file commit `1c2615c84126247d09230a8d15dfc5549f759830` and is declared
in the cmssw-tools YAML configurations. `tool-conf-src.file` applies declared
patches before collecting tool files. The patch combines the local fork's
previous build fixes with the changed upstream declarations, preserving bits'
HIP layout and translating new RPM conditionals into Bash environment setup.
It adds the new tools, OpenMP tools, ROOT library changes, and current ROCm flags.

The tool collector now loads upstream `py3-*` tool directories for bits' `py-*`
packages as well as their existing bits-specific additions. Torch keeps separate
CPU/CUDA/ROCm library directories, and the current upstream ROCm dependencies are
included. Existing valid tool overrides remain in effect.

## Validation

From the recipe checkout, with the bits checkout on PYTHONPATH:

```bash
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=/path/to/bits \
  python3 -m unittest discover -s tests -v
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=/path/to/bits \
  python3 scripts/validate-port.py /path/to/cmsdist
```

- Seven fixture tests exercise both TF modes, immutable installed caches, cache
  corruption/empty-cache handling, missing wheel handling, TF metadata consistency,
  and CUDA archive layout/source URLs for both architectures.
- Native bits parsing, include resolution and hash-input expansion, followed by
  Bash syntax checks: 501 recipe bodies, including all 467 Python packages.
- No EL9 upstream Python pin mismatches; no upstream data-name/tag mismatches.
- The tool patch applies cleanly to its pinned source. A smoke run of the actual
  tool collector rendered and parsed 17 XML files, including the new tools and
  Torch packages under bits' names, with separate vendor library directories.
- The installed Bazel 7.7.0 confirms support for the fetch/build flags used here.

Full source builds and new ONNX/MIGraphX/Sherpa patch applicability require the
corresponding downloaded source trees and remain runtime validation work. The
validator reports four existing missing dependencies of the unused legacy
`py-rep` recipe; `py-rep` remains disabled in `all_py`.

The upstream DQM GUI patch has no corresponding recipe in this bits checkout and
is recorded as outside the current recipe set. Upstream's RPM spec-directory
lookup adjustment is unnecessary for bits' native `.sh` generator. Other
pre-existing recipe deviations, such as the public DIP source fallback, are
preserved rather than rewritten as unrelated version changes.
