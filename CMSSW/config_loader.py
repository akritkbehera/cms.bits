#!/usr/bin/env python3
"""
Layered configuration loader for CMSSW virtual packages.

Layer order (later wins):
  base -> os -> flavor -> queue -> overrides

Usage:
    loader = ConfigLoader('/path/to/CMSSW')
    config = loader.load_config(
        pkg_type='cmssw',
        os='el9',
        flavor='debug',
        queue='14_2'
    )
"""

import os
import re
import sys
import warnings
from os.path import dirname, exists, join
from copy import deepcopy


def _yaml_load(content):
    """Load YAML content, with fallback to bits_helpers if available."""
    try:
        from bits_helpers.utilities import yamlLoad
        return yamlLoad(content)
    except ImportError:
        import yaml
        return yaml.safe_load(content)


def _yaml_dump(data):
    """Dump data to YAML string."""
    try:
        from bits_helpers.utilities import yamlDump
        return yamlDump(data)
    except ImportError:
        import yaml
        return yaml.safe_dump(data, default_flow_style=False)


class ConfigLoader:
    """
    Loads and merges configuration from a layered directory structure.

    Directory structure:
        CMSSW/
        ├── base/vars.yaml         # Core defaults
        ├── os/{os}/vars.yaml      # OS-specific
        ├── flavor/{flavor}/vars.yaml  # Build flavor (debug, etc.)
        └── queue/{queue}/vars.yaml    # Release queue specific

    Fallback: If layers don't exist, falls back to legacy vars.yaml.
    """

    LAYER_ORDER = ['base', 'os', 'flavor', 'queue']

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
            layer_type: One of 'base', 'os', 'flavor', 'queue'
            layer_value: The specific value (e.g., 'el9' for os)

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

    def load_config(self, pkg_type, os=None, flavor=None, queue=None):
        """
        Load configuration by merging all applicable layers.

        Layer order: base -> os -> flavor -> queue

        Args:
            pkg_type: Package type ('cmssw' or 'cmssw-tools')
            os: Operating system (e.g., 'el9', 'slc7')
            flavor: Build flavor (e.g., 'debug', 'asan')
            queue: Release queue (e.g., '14_2')

        Returns:
            Merged and resolved configuration dictionary
        """
        layers = []
        layer_values = {
            'base': None,  # base doesn't need a value
            'os': os,
            'flavor': flavor,
            'queue': queue,
        }

        # Load legacy vars.yaml as fallback base
        legacy_path = join(self.pkg_dir, 'vars.yaml')
        legacy_vars = self._load_yaml_file(legacy_path)
        if legacy_vars:
            layers.append({'variables': legacy_vars})

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

    def load_spec(self, pkg_type, spec_file=None):
        """
        Load the package specification (yaml) file.

        Args:
            pkg_type: Package type ('cmssw' or 'cmssw-tools')
            spec_file: Optional path to spec file, defaults to {pkg_type}.yaml

        Returns:
            Package specification dictionary
        """
        if spec_file is None:
            spec_file = join(self.pkg_dir, f'{pkg_type}.yaml')

        return self._load_yaml_file(spec_file)

    def load_body(self, body_file):
        """
        Load a build body template file.

        Args:
            body_file: Path to the body template file

        Returns:
            Body template as a string
        """
        if not exists(body_file):
            return ''

        with open(body_file) as f:
            return f.read().strip()


def parse_os(arch_string):
    """
    Extract the OS token from the $ARCHITECTURE environment variable.

    Format: {os}_{arch}[_{compiler}] — only the leading {os} is used.
    Examples:
        'el9_x86_64'      -> 'el9'
        'el9_amd64_gcc14' -> 'el9'
        'slc9_aarch64'    -> 'slc9'

    Args:
        arch_string: Architecture string

    Returns:
        The OS token, or None if the string is empty.
    """
    if not arch_string:
        return None
    return arch_string.split('_')[0]


def extract_flavor(suffix):
    """
    Extract build flavor from IB suffix.

    Examples:
        '_X' -> None (standard)
        '_DEBUG_X' -> 'debug'
        '_ASAN_X' -> 'asan'
        '_UBSAN_X' -> 'ubsan'
        '_CLANG_X' -> 'clang'

    Args:
        suffix: IB suffix (e.g., '_DEBUG_X', '_X')

    Returns:
        Flavor string (lowercase) or None for standard builds
    """
    if not suffix:
        return None

    # Normalize to uppercase
    suffix = suffix.upper()

    # Remove leading underscore
    if suffix.startswith('_'):
        suffix = suffix[1:]

    # Standard build suffixes (no flavor)
    if suffix in ('X', 'DEVEL', 'PATCH'):
        return None

    # Remove trailing _X, _DEVEL, _PATCH markers
    for marker in ('_X', '_DEVEL', '_PATCH'):
        if suffix.endswith(marker):
            suffix = suffix[:-len(marker)]
            break

    # Empty after stripping means standard build
    if not suffix:
        return None

    # Common flavors
    known_flavors = {
        'DEBUG': 'debug',
        'ASAN': 'asan',
        'UBSAN': 'ubsan',
        'TSAN': 'tsan',
        'CLANG': 'clang',
        'CUDA': 'cuda',
        'ROCM': 'rocm',
        'PGO': 'pgo',
    }

    # Check for known flavors in the suffix
    for known, flavor in known_flavors.items():
        if known in suffix:
            return flavor

    # Return the suffix as-is (lowercased) for unknown flavors
    return suffix.lower() if suffix else None
