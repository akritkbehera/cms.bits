"""Exercise installation behavior identified by the deployed-package inventory."""
import os
from pathlib import Path
import re
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
def body(name): return (ROOT/name).read_text().split('\n---\n',1)[1]
def run(script, cwd, env):
    p=subprocess.run(['bash','-e','-c',script],cwd=cwd,env={**os.environ,**env},capture_output=True,text=True)
    if p.returncode: raise AssertionError(p.stderr+'\n'+p.stdout)
    return p
class RepairsTest(unittest.TestCase):
    def test_pyyaml_generated_recipe_requires_native_backend(self):
        import yaml
        p=subprocess.run(['python3',str(ROOT/'pypi/package.py'),'py-PyYAML','6.0.3','py3'],capture_output=True,text=True,check=True)
        header,script=p.stdout.split('\n---\n',1);spec=yaml.safe_load(header)
        self.assertIn('libyaml',spec['requires']);self.assertIn('py-cython',spec['build_requires'])
        with tempfile.TemporaryDirectory() as t:
            # Evaluate only the override hooks; exercise the pre-build flags
            # without downloading or building PyYAML.
            override=body('pypi/py-PyYAML.file')
            out=run(override+'\neval "$PipPreBuild"; printf "%s\\n" "$CPPFLAGS" "$LDFLAGS" "$PipBuildOptions"',t,dict(LIBYAML_ROOT='/expected/libyaml'))
            self.assertIn('-I/expected/libyaml/include',out.stdout);self.assertIn('-lyaml',out.stdout);self.assertIn('--with-libyaml',out.stdout)
    def test_python_tcltk_configuration_fails_if_os_headers_unavailable(self):
        script=body('python.sh');start=script.index('TCLTK_PKG_CONFIG_PATH=');end=script.index('\nLDFLAGS="$LDFLAGS" CPPFLAGS=',start)
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);tool=p/'pkg-config';tool.write_text('#!/bin/sh\nexit 1\n');tool.chmod(0o755)
            proc=subprocess.run(['bash','-e','-c',script[start:end]],env={**os.environ,'PATH':str(p)+':/usr/bin:/bin'},capture_output=True,text=True)
            self.assertNotEqual(proc.returncode,0)
    def test_vdt_gets_version_from_selected_python(self):
        script=body('vdt.sh');start=script.index('cmake_args=(');end=script.index('\nif [[ ',start)
        with tempfile.TemporaryDirectory() as t:
            out=run(script[start:end].replace('%(cms_build_type)s','Release')+'\nprintf "%s\\n" "${cmake_args[@]}"',t,dict(INSTALLROOT='/install',PYTHON_MAJOR_MINOR_VERSION='3.12'))
            self.assertIn('-DPYTHONLIBS_VERSION_STRING=3.12',out.stdout)
    def test_clue_headers_have_public_layout(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);src=p/'source';(src/'clueLib/include').mkdir(parents=True)
            (src/'clueLib/include/CLUEAlgo.h').write_text('header')
            with tarfile.open(p/'source.tgz','w:gz') as a:a.add(src,arcname='clue')
            b=p/'build';b.mkdir();out=p/'install'
            run(body('clue.sh'),b,dict(SOURCEDIR=t,SOURCE0='source.tgz',BUILDDIR=str(b),INSTALLROOT=str(out)))
            self.assertTrue((out/'include/CLUEAlgo.h').exists());self.assertFalse((out/'include/include').exists())
    def test_runtime_setup_drops_only_build_only_deps(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);f=p/'etc/profile.d/init.sh';f.parent.mkdir(parents=True)
            f.write_text('[ -n "${GCC_PREREQUISITES_REVISION}" ] || . /absent/build/init.sh\n[ -n "${DEFAULTS_RELEASE_REVISION}" ] || . /absent/default/init.sh\n[ -n "${GCC_REVISION}" ] || . /runtime/gcc/init.sh\nexport VALUE=kept\n')
            run('bash "$HOOK"',p,dict(HOOK=str(ROOT/'hooks/runtime-setup'),INSTALLROOT=t,BUILD_REQUIRES='gcc-prerequisites defaults-release gcc',RUNTIME_REQUIRES='gcc'))
            self.assertNotIn('/absent',f.read_text());self.assertIn('/runtime/gcc',f.read_text());self.assertIn('VALUE=kept',f.read_text())
    def test_runtime_setup_repairs_deployed_gcc_without_build_tree(self):
        original=Path('/data/akb/sw/el9_amd64_gcc14/external/gcc/14.3.1-83803646d509b9978d8c839a05e0bb3f31cfdd3b/etc/profile.d/init.sh')
        if not original.exists(): self.skipTest('deployed GCC fixture unavailable')
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);f=p/'etc/profile.d/init.sh';f.parent.mkdir(parents=True);f.write_text(original.read_text())
            run('bash "$HOOK"; . "$INSTALLROOT/etc/profile.d/init.sh"; gcc -dumpfullversion',p,dict(HOOK=str(ROOT/'hooks/runtime-setup'),INSTALLROOT=t,BUILD_REQUIRES='gcc-prerequisites defaults-release',RUNTIME_REQUIRES=''))
    def test_tensorflow_retains_original_commands(self):
        text=(ROOT/'pypi/py-tensorflow.file').read_text();hook=re.search(r"PipPostBuild='(.*?)'",text,re.S).group(1)
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);(p/'bin').mkdir();(p/'bin/saved_model_cli').write_text('script');(p/'bin/tensorboard').write_text('excluded')
            run(hook,p,dict(INSTALLROOT=t))
            self.assertEqual((p/'bin/saved_model_cli').read_text(),'script');self.assertEqual((p/'bin/saved_model_cli').readlink(),Path('saved_model_cli3'));self.assertFalse((p/'bin/tensorboard').exists())
    def test_rccl_compatibility_paths_resolve(self):
        hook=re.search(r"export ROCM_POST_INSTALL_HOOK='(.*?)'",body('rccl.sh'),re.S).group(1)
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);(p/'lib/cmake/rccl').mkdir(parents=True);(p/'lib/librccl.so').write_text('library');(p/'lib/cmake/rccl/rccl-config.cmake').write_text('config')
            run(hook,p,dict(INSTALLROOT=t))
            self.assertEqual((p/'rccl/lib/librccl.so').read_text(),'library');self.assertEqual((p/'rccl/lib/cmake/rccl-config.cmake').read_text(),'config')
    def test_gcc_stripping_keeps_executable_functional(self):
        text=body('gcc.sh');strip=text[text.index('# CMSDIST strips these binaries;'):]
        import shutil
        if not shutil.which('gcc') or not shutil.which('strip'):self.skipTest('host build tools unavailable')
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);(p/'bin').mkdir();(p/'main.c').write_text('int main(void){return 0;}')
            subprocess.run(['/usr/bin/gcc','-g',str(p/'main.c'),'-o',str(p/'bin/gcc')],check=True)
            (p/'bin/strip').symlink_to(shutil.which('strip'));size=(p/'bin/gcc').stat().st_size
            (p/'bin/gcc-helper').write_text('#!/bin/sh\nexit 0\n');(p/'bin/gcc-link').symlink_to('gcc')
            run(strip,p,dict(INSTALLROOT=t));self.assertLess((p/'bin/gcc').stat().st_size,size)
            subprocess.run([str(p/'bin/gcc')],check=True);self.assertTrue((p/'bin/gcc-link').is_symlink());self.assertTrue((p/'bin/gcc-helper').read_text().startswith('#!'))
    def test_hwloc_uses_declared_rocm_smi_root(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t);src=p/'source';src.mkdir();(src/'configure').write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$BUILDDIR/configure.args"\n');(src/'configure').chmod(0o755)
            with tarfile.open(p/'source.tgz','w:gz') as a:a.add(src,arcname='hwloc')
            b=p/'build';b.mkdir();tools=p/'tools';tools.mkdir();(tools/'make').write_text('#!/bin/sh\nexit 0\n');(tools/'make').chmod(0o755)
            run(body('hwloc.sh'),b,dict(SOURCEDIR=t,SOURCE0='source.tgz',BUILDDIR=str(b),INSTALLROOT=str(p/'install'),PATH=str(tools)+':'+os.environ['PATH'],ROCM_ROOT='',ROCM_SMI_LIB_ROOT='/expected/smi',CUDA_ROOT='/expected/cuda',LIBPCIACCESS_ROOT='/pci',LIBXML2_ROOT='/xml',NUMACTL_ROOT='/numa'))
            args=(b/'configure.args').read_text();self.assertIn('--with-rocm=/expected/smi',args);self.assertIn('--enable-plugins=cuda,nvml,rsmi',args)
if __name__=='__main__':unittest.main()
