#!/usr/bin/env python3
from os.path import exists, dirname, join
from bits_helpers.utilities import yamlLoad, yamlDump


def _recipeLines(package, version, recipe_dir):
  build_requires = ["setuptools", "pip"]
  if not package in ["py-wheel", "py-flit-core"]:
    build_requires.append("py-flit-core")
  prepend_path = {"PYTHON3PATH": ["%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"]}
  pypi_name=package[3:]
  variables = {
    "pypi_source_name": pypi_name.replace("-","_"),
    "pypi_name": pypi_name,
    "pypi_source_opt": "--no-binary=:all:",
    "pypi_download_opts": "--python-version=%%(python_major_minor_str)s+--abi=cp%%(python_major_minor_str)s+--no-deps+%%(pypi_source_opt)s",
    "pypi_pip": "pip3",
    "pypi_source_name": "%s-%%(version)s.tar.gz" % pypi_name,
  }

  sources = ["pip://%%(pypi_name)s/%%(version)s?pip_options=%%(pypi_download_opts)s&pip=%%(pypi_pip)s&output=/%%(pypi_source_name)s"]
  recipe = ""
  header = ""
  override_file = join(recipe_dir, "%s.file" % package)
  if exists(override_file):
    with open(override_file) as ref:
      header,recipe = ref.read().split("---", 1)
  header = "package: %s\nversion: \"%s\"\n%s" % (package, version, header.strip())
  spec = yamlLoad(header.strip())
  var = spec.get("variables", {})
  for k, v in var.items():
    variables[k] = v
  spec["variables"] = variables
  if not "sources" in spec:
    spec["sources"] = sources
  if "build_requires" in spec:
    spec["build_requires"].extend(build_requires)
  else:
    spec["build_requires"] = build_requires
  if "requires" in spec:
      spec["requires"].extend(["gcc", "Python"])
  else:
      spec["requires"] = ["gcc", "Python"]
  prepath = spec.get("prepend_path", {})
  if prepath:
    for k, v in prepath.items():
      if k in prepend_path:
        if isinstance(v,str):
          prepend_path[k].append(v)
        else:
          prepend_path[k].extend(v)
      else:
        prepend_path[k] = v
  spec["prepend_path"] = prepend_path
  yield yamlDump(spec).strip()
  yield "---"
  yield 'export Pypi_name="%s"' % variables["pypi_name"]
  if recipe.strip():
    yield recipe.strip()

  with open(join(recipe_dir, "build-with-pip.file")) as ref:
    yield ref.read()


def generateRecipe(package, version, recipe_dir=dirname(__file__)):
  """Return the generated recipe, including the CLI trailing newline."""
  return "\n".join(_recipeLines(package, version, recipe_dir)) + "\n"


if __name__ == "__main__":
  import sys

  for line in _recipeLines(sys.argv[1], sys.argv[2], dirname(sys.argv[0])):
    print(line)
