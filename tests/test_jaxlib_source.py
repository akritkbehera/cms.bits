"""jaxlib's binary-only PyPI source must use bits' pip wheel fallback."""
from copy import deepcopy
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch
import yaml

from bits_helpers.build import prepare_hash_inputs
from bits_helpers.download import downloadPip
from bits_helpers.recipe import parseRecipe

ROOT = Path(__file__).resolve().parents[1]


class JaxlibSourceTest(unittest.TestCase):
    def source_for(self, machine):
        generated = subprocess.check_output(
            ['python3', str(ROOT / 'pypi/package.py'), 'py-jaxlib', '0.11.2', 'py3'],
            text=True)

        class Reader:
            url = str(ROOT / 'generated-py-jaxlib.sh')

            def __call__(self):
                return generated

        error, spec, body = parseRecipe(Reader())
        self.assertIsNone(error)
        spec['recipe'] = body
        spec['scm_refs'] = {}
        spec['variables']['platform_machine'] = machine
        defaults = yaml.safe_load((ROOT / 'defaults-release.sh').read_text().split('---', 1)[0])['variables']
        prepare_hash_inputs(spec, {'Python': {'version': '3.12.11'}}, ['release'],
                            deepcopy(defaults), str(ROOT))
        return spec['sources'][0]

    def test_wheel_selection_uses_pip_fallback_on_both_architectures(self):
        for machine in ('x86_64', 'aarch64'):
            with self.subTest(machine=machine):
                source = self.source_for(machine)
                wheel = f'jaxlib-0.11.2-cp312-cp312-manylinux_2_27_{machine}.whl'
                self.assertTrue(source.startswith('pip://jaxlib/0.11.2?'), source)
                self.assertIn('--only-binary=:all:', source)
                self.assertIn(f'--platform=manylinux_2_27_{machine}', source)
                self.assertTrue(source.endswith('/' + wheel), source)
                with patch('bits_helpers.download.downloadUrllib2', return_value=False), \
                     patch('bits_helpers.download.getstatusoutput', return_value=(0, '')) as command:
                    self.assertTrue(downloadPip(source, '/tmp/jaxlib-test', '/tmp'))
                line = command.call_args.args[0]
                self.assertIn('pip3 download', line)
                self.assertIn('--only-binary=:all:', line)
                self.assertIn('--platform=manylinux_2_27_' + machine, line)
                self.assertIn('jaxlib==0.11.2', line)
                self.assertIn(wheel, line)


if __name__ == '__main__':
    unittest.main()
