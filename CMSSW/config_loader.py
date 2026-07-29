#!/usr/bin/env python3
"""
Layered configuration loader for CMSSW virtual packages.

Layer order (later wins):
  base -> flavor -> overrides

Usage:
    loader = ConfigLoader('/path/to/CMSSW')
    config = loader.load_config(
        pkg_type='cmssw',
        flavor='debug',
    )
"""

import warnings
from os.path import exists, join
from copy import deepcopy


def _yaml_load(content):
    """Load YAML content, with fallback to bits_helpers if available."""
    try:
        from bits_helpers.utilities import yamlLoad
        return yamlLoad(content)
    except ImportError:
        import yaml
        return yaml.safe_load(content)


class ConfigLoader:
    """
    Loads and merges configuration from a layered directory structure.

    Directory structure:
        CMSSW/
        ├── base/vars.yaml         # Core defaults
        └── flavor/{flavor}/vars.yaml  # Build flavor (debug, etc.)
    """

    LAYER_ORDER = ['base', 'flavor']

    def __init__(self, pkg_dir):
        """
        Initialize ConfigLoader.

        Args:
            pkg_dir: Path to the CMSSW directory containing config layers
        """
        self.pkg_dir = pkg_dir
        self._cache = {}

    def _load_yaml_file(self, path):
        """Load a YAML file, returning empty dict if not found."""
        if path in self._cache:
            return deepcopy(self._cache[path])

        if not exists(path):
            return {}

        try:
            with open(path) as f:
                data = _yaml_load(f.read())
            self._cache[path] = data or {}
            return deepcopy(self._cache[path])
        except Exception as e:
            warnings.warn(f"Failed to load {path}: {e}")
            return {}

    def _get_layer_path(self, layer_type, layer_value):
        """
        Get the path to a layer's vars.yaml file.

        Args:
            layer_type: One of 'base', 'flavor'
            layer_value: The specific value (e.g., 'debug' for flavor)

        Returns:
            Path to the vars.yaml file for this layer
        """
        if layer_type == 'base':
            return join(self.pkg_dir, 'base', 'vars.yaml')
        return join(self.pkg_dir, layer_type, layer_value, 'vars.yaml')

    def _deep_merge(self, base, override):
        """
        Deep merge override into base.

        - Dictionaries are merged recursively
        - Lists are replaced (not concatenated)
        - Keys starting with 'remove_' delete corresponding keys
        - None values in override delete the key from base

        Args:
            base: Base dictionary
            override: Override dictionary

        Returns:
            Merged dictionary
        """
        result = deepcopy(base)

        for key, value in override.items():
            # Handle remove_ prefix - delete key from result
            if key.startswith('remove_'):
                target_key = key[7:]  # Remove 'remove_' prefix
                if target_key in result:
                    del result[target_key]
                continue

            # Handle None value - delete key
            if value is None:
                if key in result:
                    del result[key]
                continue

            # Handle nested dict - recursive merge
            if isinstance(value, dict) and key in result and isinstance(result[key], dict):
                result[key] = self._deep_merge(result[key], value)
            else:
                result[key] = deepcopy(value)

        return result

    def merge_layers(self, *layers):
        """
        Merge multiple configuration layers.

        Args:
            *layers: Variable number of config dictionaries

        Returns:
            Merged configuration dictionary
        """
        result = {}
        for layer in layers:
            if layer:
                result = self._deep_merge(result, layer)
        return result

    def resolve_variables(self, config, max_passes=10):
        """
        Resolve %(varname)s placeholders in config values.

        Performs multiple passes to handle nested references.
        Uses variables from the 'variables' key in the config.

        Args:
            config: Configuration dictionary
            max_passes: Maximum resolution passes (default 10)

        Returns:
            Config with resolved variable references
        """
        result = deepcopy(config)
        variables = result.get('variables', {})

        # Resolve variables within themselves first
        for _ in range(max_passes):
            changed = False
            new_vars = {}
            for key, value in variables.items():
                if isinstance(value, str) and '%(' in value:
                    try:
                        new_value = value % variables
                        if new_value != value:
                            changed = True
                        new_vars[key] = new_value
                    except (KeyError, ValueError):
                        new_vars[key] = value
                else:
                    new_vars[key] = value
            variables = new_vars
            if not changed:
                break

        result['variables'] = variables

        # Now resolve variables in other config values
        def resolve_value(val):
            if isinstance(val, str) and '%(' in val:
                try:
                    return val % variables
                except (KeyError, ValueError):
                    return val
            elif isinstance(val, dict):
                return {k: resolve_value(v) for k, v in val.items()}
            elif isinstance(val, list):
                return [resolve_value(item) for item in val]
            return val

        for key in result:
            if key != 'variables':
                result[key] = resolve_value(result[key])

        return result

    def load_config(self, pkg_type, flavor=None):
        """
        Load configuration by merging all applicable layers.

        Layer order: base -> flavor

        Args:
            pkg_type: Package type ('cmssw' or 'cmssw-tools')
            flavor: Build flavor (e.g., 'debug', 'asan')

        Returns:
            Merged and resolved configuration dictionary
        """
        layers = []
        layer_values = {
            'base': None,  # base doesn't need a value
            'flavor': flavor,
        }

        # Load each layer in order
        for layer_type in self.LAYER_ORDER:
            layer_value = layer_values.get(layer_type)

            if layer_type == 'base':
                path = self._get_layer_path('base', None)
            elif layer_value:
                path = self._get_layer_path(layer_type, layer_value)
            else:
                continue

            layer_data = self._load_yaml_file(path)
            if layer_data:
                # If the layer file contains bare key-value pairs (no 'variables' key),
                # wrap them as variables for consistency
                if 'variables' not in layer_data and not any(
                    k in layer_data for k in ('requires', 'sources', 'build_requires', 'env')
                ):
                    layer_data = {'variables': layer_data}
                layers.append(layer_data)

        # Merge all layers
        config = self.merge_layers(*layers)

        # Resolve variable references
        config = self.resolve_variables(config)

        return config
