"""Shared toolbox recipes must resolve under the ordinary release defaults."""
from copy import deepcopy
import unittest

from bits_helpers.build import prepare_hash_inputs
from bits_helpers.recipe import parseRecipe
from test_tensorflow_cache import ROOT, Reader


class ToolConfigDefaultsTest(unittest.TestCase):
    def expand_coral(self, overrides=None):
        error, defaults, _ = parseRecipe(Reader(ROOT / 'defaults-release.sh'))
        self.assertIsNone(error)
        error, spec, body = parseRecipe(Reader(ROOT / 'coral-tools.sh'))
        self.assertIsNone(error)
        spec['recipe'] = body
        spec.setdefault('variables', {}).update(overrides or {})
        spec['scm_refs'] = {}
        prepare_hash_inputs(spec, {'Python': {'version': '3.12.11'}}, ['release'],
                            deepcopy(defaults['variables']), str(ROOT))
        return spec['recipe']

    def test_coral_uses_release_cuda_host_baseline(self):
        body = self.expand_coral()
        self.assertIn('export CUDA_HOST_MIN_MICROARCH_NAME="x86-64-v2"', body)
        self.assertNotIn('%(cuda_host_min_microarch_name)s', body)

    def test_recipe_can_override_release_cuda_host_baseline(self):
        body = self.expand_coral({'cuda_host_min_microarch_name': 'x86-64-v3'})
        self.assertIn('export CUDA_HOST_MIN_MICROARCH_NAME="x86-64-v3"', body)


if __name__ == '__main__':
    unittest.main()
