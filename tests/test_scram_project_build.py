"""Exercise the SCRAM compile/logging flow with a failing SCRAM fixture."""
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]
MOCK = r'''#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
with open(os.environ['CALLS'], 'a') as out:
    out.write(json.dumps(args) + '\n')
if args == ['runtime', '-sh']:
    print('unset BUILD_LOG')
    sys.exit(0)
assert args[0] == 'build'
assert os.environ['BUILD_LOG'] == 'yes'
print('SCRAM stdout: ' + ' '.join(args))
print('SCRAM stderr: ' + ' '.join(args), file=sys.stderr)
if 'echo_CXX' in args:
    sys.exit(0)
logs = pathlib.Path(os.environ['INSTALLROOT']) / 'tmp/test_arch/cache/log/src/Test/Package'
logs.mkdir(parents=True, exist_ok=True)
(logs / 'build.log').write_text('compiler diagnostic\n')
if os.environ.get('FAIL_TARGET') in args:
    assert '-k' in args
    print('Independent package built')
    sys.exit(7)
'''


class ScramBuildTest(unittest.TestCase):
    def run_build(self, fail='', ignore='', pre='', post='', tee_failure=False):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        root = Path(temp.name)
        install = root / 'install'
        (install / 'config').mkdir(parents=True)
        (install / 'config/Self.xml').write_text('<tool/>')
        build = root / 'build'
        build.mkdir()
        logs = root / 'web/logs'
        (logs / 'src').mkdir(parents=True)
        if tee_failure:
            (logs / 'build.log').mkdir()
        mock = root / 'scram'
        mock.write_text(MOCK)
        mock.chmod(0o755)
        variables = yaml.safe_load((ROOT / 'CMSSW/base/vars.yaml').read_text())
        variables.update(ignore_compile_errors=ignore, prebuildtarget=pre, postbuildtarget=post)
        body = (ROOT / 'scram-project-build.file').read_text() % variables
        helpers = body.split('log_section "Block 1:')[0]
        compile_body = body.split('log_section "Block 6:')[1]
        compile_body = 'log_section "Block 6:' + compile_body.split('log_section "Block 7:')[0]
        script = helpers + '\n' + '''
SCRAMCMD="$MOCK_SCRAM"
SCRAM_LOGS_READY=1
export BUILD_LOG=yes
BUILDTARGET=release-build
EXTRA_CXXFLAGS='-g -O2'
SRCTREE=src
''' + compile_body + '''
archive_scram_logs
rm -rf "$INSTALLROOT/tmp"
'''
        env = dict(os.environ, NO_COLOR='1', JOBS='3', ARCHITECTURE='test_arch',
                   PKGNAME='CMSSW_20_1_X', INSTALLROOT=str(install), BUILDDIR=str(build),
                   LOG_WEB_DIR=str(root / 'web'), MOCK_SCRAM=str(mock),
                   CALLS=str(root / 'calls'), FAIL_TARGET=fail)
        result = subprocess.run(['bash', '-eo', 'pipefail'], input=script, env=env,
                                text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        calls = [json.loads(line) for line in (root / 'calls').read_text().splitlines()]
        with tarfile.open(logs / 'src/src-logs.tgz') as archive:
            self.assertEqual(archive.extractfile('./Test/Package/build.log').read(), b'compiler diagnostic\n')
        return result, calls, root

    def test_failure_keeps_logs_and_returns_scram_status(self):
        result, calls, root = self.run_build(fail='release-build')
        self.assertEqual(result.returncode, 7, result.stdout)
        self.assertTrue((root / 'build/build-errors').exists())
        self.assertTrue((root / 'install/tmp').exists())
        log = (root / 'web/logs/build.log').read_text()
        self.assertIn('SCRAM stdout', log)
        self.assertIn('SCRAM stderr', log)
        self.assertIn('Independent package built', log)
        self.assertIn(['build', '-f', 'outputlog'], calls)
        self.assertNotIn('Compile phase done', result.stdout)

    def test_success_archives_before_tmp_removal(self):
        result, calls, root = self.run_build(post='post-target')
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertFalse((root / 'install/tmp').exists())
        main = next(args for args in calls if 'release-build' in args)
        self.assertIn('-k', main)
        self.assertEqual(main[main.index('-j') + 1], '3')
        self.assertIn('USER_CXXFLAGS=-g -O2', main)

    def test_explicit_ignore_continues_to_postbuild(self):
        result, calls, _ = self.run_build(fail='release-build', ignore='yes', post='post-target')
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertTrue(any('post-target' in args for args in calls))

    def test_auxiliary_failures_also_archive_logs(self):
        for target, kwargs in [('pre-target', {'pre': 'pre-target'}),
                               ('post-target', {'post': 'post-target'})]:
            with self.subTest(target=target):
                result, _, _ = self.run_build(fail=target, **kwargs)
                self.assertEqual(result.returncode, 7, result.stdout)

    def test_tee_failure_is_not_success(self):
        result, _, _ = self.run_build(tee_failure=True)
        self.assertNotEqual(result.returncode, 0, result.stdout)


if __name__ == '__main__':
    unittest.main()
