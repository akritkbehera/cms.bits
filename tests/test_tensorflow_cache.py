"""Exercise both included TensorFlow modes without downloading or compiling TF.

Run with PYTHONPATH pointing to the bits checkout:
    python3 -m unittest discover -s tests -v
"""
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

from bits_helpers.recipe import parseRecipe
from bits_helpers.utilities import resolve_spec_data

ROOT = Path(__file__).resolve().parents[1]


class Reader:
    def __init__(self, path):
        self.url = str(path)

    def __call__(self):
        return Path(self.url).read_text()


def recipe(name):
    error, spec, body = parseRecipe(Reader(ROOT / (name + '.sh')))
    if error:
        raise RuntimeError(error)
    body = resolve_spec_data(spec, body, ['release'], default_vars={
        'override_microarch_name': '', 'cms_cxx_std': '20',
        'cms_build_type': 'Release'}, strict=False)
    return spec, body


MOCK_BAZEL = r'''#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
with open(os.environ['BAZEL_TEST_LOG'], 'a') as f:
    f.write(json.dumps(args) + '\n')
cache = pathlib.Path(next(a.split('=', 1)[1] for a in args if a.startswith('--repository_cache=')))
blob = cache / 'content_addressable/sha256/fixture/file'
if 'fetch' in args:
    assert 'build' not in args
    assert '--repository_disable_download' not in args
    if not os.environ.get('TEST_EMPTY_CACHE'):
        blob.parent.mkdir(parents=True, exist_ok=True)
        blob.write_text('a fetched dependency')
else:
    assert 'build' in args
    assert '--repository_disable_download' in args
    assert blob.read_text() == 'a fetched dependency'
    # A build can update its private copy without writing the installed artifact.
    (cache / 'build-only-marker').write_text('private')
    root = pathlib.Path.cwd()
    if args[-1] == '//third_party/py/numpy':
        output = root / 'bazel-user-root/test/execroot/org_tensorflow/bazel-out'
        output.mkdir(parents=True)
        (output.parents[2] / 'external/pypi_numpy').mkdir(parents=True)
        (root / 'bazel-out').symlink_to(output)
        (root / 'outputs').mkdir()
        (root / 'bazel-bin').symlink_to(root / 'outputs')
    else:
        assert args[-1] == '//tensorflow/tools/pip_package:wheel'
        output = root / 'outputs'
        if not os.environ.get('TEST_NO_WHEEL'):
            wheel = output / 'tensorflow/tools/pip_package/wheel_house/tensorflow-2.21.0-test.whl'
            wheel.parent.mkdir(parents=True)
            wheel.write_text('wheel fixture')
        libs = output / 'external/ducc'
        libs.mkdir(parents=True)
        for name in ('libfft.pic.a', 'libfft_wrapper.pic.a'):
            (libs / name).write_text('runtime fixture')
'''


class TensorFlowCacheTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.sources = self.base / 'sources'
        self.sources.mkdir()
        source = self.base / 'tensorflow-2.21.0'
        files = {
            'third_party/systemlibs/pybind11.BUILD': 'lib/python3.12/site-packages/pybind11"\n',
            'third_party/cms/workspace.bzl': 'def repos():\n    pass\n',
            'third_party/cms/pypi.BUILD': '# fixture\n',
            'tensorflow/core/lib/gif/BUILD': '"//conditions:default": ["-ldl"],\n',
            'requirements_lock_3_14.txt': 'numpy==1.0\n',
            'configure': '#!/bin/bash\ntest "$TF_PYTHON_VERSION" = 3.14\n',
        }
        for name, content in files.items():
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
        (source / 'configure').chmod(0o755)
        with tarfile.open(self.sources / 'tensorflow.tgz', 'w:gz') as archive:
            archive.add(source, arcname=source.name)
        (self.sources / 'tensorflow.patch').write_text('fixture')
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.executable('bazel', MOCK_BAZEL)
        # Upstream patch applicability is a separate source check; here we exercise
        # the cache/build control flow and package layout.
        self.executable('patch', '#!/bin/sh\ncat > /dev/null\n')
        self.executable('java', '#!/bin/sh\necho \'openjdk version "21.0.1"\' >&2\n')
        self.log = self.base / 'bazel-invocations.jsonl'
        self.cache_install = self.base / 'cache-install'

    def executable(self, name, content):
        path = self.bin / name
        path.write_text(content)
        path.chmod(0o755)

    def run_stage(self, name, extra=None, success=True):
        spec, body = recipe(name)
        work = self.base / (name + '-work')
        work.mkdir()
        install = self.cache_install if name.endswith('-cache') else self.base / 'build-install'
        env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ['PATH'])
        env.update({
            'PKG_VERSION': '2.21.0', 'BUILDDIR': str(work), 'INSTALLROOT': str(install),
            'SOURCEDIR': str(self.sources), 'SOURCE0': 'tensorflow.tgz',
            'PATCH0': 'tensorflow.patch', 'JOBS': '2', 'JAVA_HOME': str(self.base),
            'LLVM_VERSION': '21.1.4', 'PYTHON_MAJOR_MINOR_VERSION': '3.14',
            'PYTHON3_LIB_SITE_PACKAGES': 'lib/python3.14/site-packages',
            'PYTHON3PATH': '', 'LD_LIBRARY_PATH': '', 'CXXSTD': '23',
            'BAZEL_TEST_LOG': str(self.log),
            'TENSORFLOW_SOURCES_CACHE_ROOT': str(self.cache_install),
        })
        for dep in spec['requires']:
            env[dep.upper().replace('-', '_') + '_ROOT'] = str(self.base / 'deps' / dep)
        env.update(extra or {})
        result = subprocess.run(['bash', '-e', '-c', body], cwd=work, env=env,
                                text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout)
        return result, install

    def test_cache_then_build_and_installed_cache_stays_immutable(self):
        _, cache = self.run_stage('tensorflow-sources-cache')
        manifest = (cache / 'SHA256SUMS').read_text()
        self.assertIn('repository_cache/content_addressable/', manifest)
        self.assertNotIn(str(self.base), manifest)
        _, install = self.run_stage('tensorflow-sources')
        self.assertTrue((install / 'tensorflow-2.21.0-test.whl').is_file())
        self.assertTrue((install / 'lib-xla-runtime/libfft.pic.a').is_file())
        self.assertFalse((cache / 'repository_cache/build-only-marker').exists())
        self.assertEqual((cache / 'SHA256SUMS').read_text(), manifest)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        self.assertEqual(len(calls), 3)  # fetch, numpy build, wheel build
        for args in calls:
            self.assertIn('--action_env=TF_PYTHON_VERSION=3.14', args)
            self.assertIn('--cxxopt=-std=c++20', args)  # cap at TF's supported standard

    def test_empty_cache_is_rejected(self):
        result, _ = self.run_stage('tensorflow-sources-cache', {'TEST_EMPTY_CACHE': '1'}, False)
        self.assertIn('empty repository cache', result.stdout)

    def test_corrupted_cache_is_rejected_before_compilation(self):
        _, cache = self.run_stage('tensorflow-sources-cache')
        blob = next((cache / 'repository_cache').rglob('file'))
        blob.write_text('corrupted')
        self.run_stage('tensorflow-sources', success=False)
        self.assertEqual(len(self.log.read_text().splitlines()), 1)

    def test_missing_wheel_is_rejected(self):
        self.run_stage('tensorflow-sources-cache')
        result, _ = self.run_stage('tensorflow-sources', {'TEST_NO_WHEEL': '1'}, False)
        self.assertIn('Expected one TensorFlow wheel', result.stdout)

    def test_cache_and_build_sources_match_and_dependency_is_acyclic(self):
        cache, _ = recipe('tensorflow-sources-cache')
        build, _ = recipe('tensorflow-sources')
        for key in ('version', 'variables', 'sources', 'patches', 'requires'):
            self.assertEqual(cache[key], build[key])
        self.assertIn('tensorflow-sources-cache', build['build_requires'])
        self.assertNotIn('tensorflow-sources', cache['build_requires'])


if __name__ == '__main__':
    unittest.main()
