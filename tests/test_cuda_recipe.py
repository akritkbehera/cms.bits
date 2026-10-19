"""Check CUDA's new redistributable-driver layout with small source fixtures."""
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest
from unittest.mock import patch

from bits_helpers.build import prepare_hash_inputs
from test_tensorflow_cache import ROOT, recipe

INSTALLER = r'''#!/bin/sh
set -e
for arg; do
  case "$arg" in --installpath=*) dest=${arg#--installpath=};; esac
done
mkdir -p "$dest/lib64/stubs" "$dest/include" "$dest/extras/CUPTI/lib64" "$dest/extras/CUPTI/include" "$dest/bin" "$dest/share" "$dest/compute-sanitizer" "$dest/nvvm"
for name in libcudadevrt.a libcudart_static.a libdrop.a libcudart.so; do
  echo runtime > "$dest/lib64/$name"
done
echo header > "$dest/include/cuda.h"
echo cupti > "$dest/extras/CUPTI/lib64/libcupti.so"
echo header > "$dest/extras/CUPTI/include/cupti.h"
printf '#!/bin/sh\n# cuda-gdb\nexit 0\n' > "$dest/bin/cuda-gdb"
echo tool > "$dest/compute-sanitizer/compute-sanitizer"
printf 'TOP = $(_HERE_)/..\nINCLUDES = $(TOP)/$(_TARGET_DIR_)/include\nLIB = lib$(_TARGET_SIZE_)\n' > "$dest/bin/nvcc.profile"
'''


class CudaRecipeTest(unittest.TestCase):
    def test_source_urls_select_both_supported_architectures(self):
        for arch, toolkit_suffix, driver_arch in [
                ('x86_64', 'linux', 'linux-x86_64'),
                ('aarch64', 'linux_sbsa', 'linux-sbsa')]:
            spec, _ = recipe('cuda')
            spec['recipe'] = ''
            with patch('bits_helpers.utilities.platform.machine', return_value=arch):
                prepare_hash_inputs(spec, {'Python': {'version': '3.12.11'}},
                                    ['release'], {}, str(ROOT))
            self.assertTrue(spec['sources'][0].endswith('cuda_13.4.2_' + toolkit_suffix + '.run'))
            self.assertIn('/' + driver_arch + '/', spec['sources'][1])
            self.assertIn('615.71.09-archive.tar.xz', spec['sources'][1])

    def test_redistributable_libraries_and_nvcc_profile_are_installed(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / 'source'
            source.mkdir()
            (source / 'cuda.run').write_text(INSTALLER)
            driver = root / 'driver'
            (driver / 'lib').mkdir(parents=True)
            (driver / 'sbin').mkdir()
            version = '615.71.09'
            for name in ['libcuda.so.' + version, 'libcudadebugger.so.' + version,
                         'libnvidia-gpucomp.so.' + version, 'libnvidia-nvvm.so.' + version,
                         'libnvidia-nvvm70.so.4', 'libnvidia-pkcs11.so.' + version,
                         'libnvidia-pkcs11-openssl3.so.' + version,
                         'libnvidia-ptxjitcompiler.so.' + version,
                         'libnvidia-tileiras.so.' + version, 'libnvidia-ml.so.' + version]:
                (driver / 'lib' / name).write_text('driver fixture')
            (driver / 'sbin/nvidia-smi').write_text('tool fixture')
            with tarfile.open(source / 'driver.tar.xz', 'w:xz') as archive:
                archive.add(driver, arcname='driver')
            work = root / 'work'
            work.mkdir()
            install = root / 'install'
            bin_dir = root / 'bin'
            bin_dir.mkdir()
            # The real recipe keeps the terminal wrapper. Here run its command
            # directly so the fixture test does not need a pseudo-terminal.
            wrapper = bin_dir / 'script'
            wrapper.write_text('#!/bin/sh\nexec /bin/sh -c "$2"\n')
            wrapper.chmod(0o755)
            _, body = recipe('cuda')
            env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ['PATH'])
            env.update(BUILDDIR=str(work), INSTALLROOT=str(install),
                       SOURCEDIR=str(source), SOURCE0='cuda.run', SOURCE1='driver.tar.xz',
                       PYTHON_ROOT=str(root / 'python'))
            result = subprocess.run(['bash', '-e', '-c', body], cwd=work, env=env,
                                    text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            self.assertEqual(result.returncode, 0, result.stdout)
            self.assertTrue((install / 'drivers/libnvidia-gpucomp.so').is_file())
            self.assertTrue((install / 'drivers/libnvidia-nvvm70.so').is_file())
            self.assertTrue((install / 'lib64/stubs/libcudadebugger.so').is_file())
            self.assertTrue((install / 'lib64/stubs/libnvidia-ml.so').is_file())
            self.assertFalse((install / 'lib64/libdrop.a').exists())
            self.assertTrue((install / 'lib64/libcudadevrt.a').is_file())
            profile = (install / 'bin/nvcc.profile').read_text()
            self.assertIn('TOP = ' + str(install), profile)
            self.assertNotIn('$(_HERE_)', profile)
            self.assertNotIn('$(_TARGET_', profile)
            self.assertIn('export PYTHONHOME=', (install / 'bin/cuda-gdb').read_text())


if __name__ == '__main__':
    unittest.main()
