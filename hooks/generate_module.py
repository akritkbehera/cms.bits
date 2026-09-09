#!/usr/bin/env python3
"""Translate a package's resolved environment into a Tcl modulefile.

Driven by hooks/generate_module. Consumes two `env -0` dumps -- the build
environment before and after sourcing the package's own
etc/profile.d/init.sh -- and emits the difference as modulefile directives.

The diff is exactly this package's own contribution: its dependencies were
already sourced into the build environment by build_template.sh before the
recipe ran, so they do not appear. That is the property that lets the modulefile
delegate dependencies to `module load` while still reproducing `source init.sh`
byte for byte in effect.

Every absolute path that points into the install tree is rewritten to a Tcl
expression anchored at $::env(BASEDIR), which BASE/1.0 sets at load time: the
package's own root becomes $<PKG>_ROOT, and anything else in the tree becomes
$::env(BASEDIR)/<family>/<name>/<verrev>. Anything left pointing at the build
tree is a bug; the caller greps for it and fails the build.
"""

import argparse
import os
import posixpath
import re
import sys

# Variables that describe the build or the shell rather than the package.
# RECC_* are the remote-compilation cache's prefix maps, rebuilt per build and
# meaningless at runtime; WORK_DIR / BITS_ARCH_PREFIX are the very build-tree
# anchors the modulefile must not carry.
SKIP_EXACT = frozenset({
    "_", "PWD", "OLDPWD", "SHLVL", "WORK_DIR", "BITS_ARCH_PREFIX",
    "BITS_BUILD_WORK_DIR", "BITS_CONFIG_DIR", "INSTALLROOT", "BUILDDIR",
    "BUILDROOT", "SOURCEDIR", "PKGPATH",
})
SKIP_PREFIX = ("RECC_", "BASH_FUNC_", "_bits_")

# Path-list variables get prepend-path/append-path (composable across modules)
# rather than setenv (last-writer-wins). Anything whose name ends in PATH counts;
# these are the ones that do not.
PATHLIKE_EXTRA = frozenset({"MANPATH", "INFOPATH", "LD_LIBRARY_PATH"})


def is_pathlike(name):
  return name.endswith("PATH") or name in PATHLIKE_EXTRA


def read_env0(path):
  """Parse a NUL-separated `env -0` dump into an ordered dict."""
  with open(path, "rb") as handle:
    blob = handle.read()
  out = {}
  for record in blob.split(b"\0"):
    if not record:
      continue
    name, sep, value = record.partition(b"=")
    if not sep:
      continue
    out[name.decode("utf-8", "surrogateescape")] = value.decode(
        "utf-8", "surrogateescape")
  return out


class PathRewriter:
  """Replace absolute install paths with Tcl expressions.

  Substitutions are applied longest-first so that the package's own root wins
  over any shorter directory that happens to prefix it.
  """

  # A byte that cannot occur in an environment variable value we care about,
  # used to fence off already-substituted Tcl so the escaper leaves it alone.
  MARK = "\x01"

  def __init__(self, rules):
    # rules: list of (absolute_path, tcl_expression)
    self.rules = sorted(rules, key=lambda r: len(r[0]), reverse=True)

  def substitute(self, value):
    """Return *value* with install paths replaced by fenced Tcl expressions."""
    for abs_path, tcl in self.rules:
      if abs_path in value:
        value = value.replace(abs_path, "%s%s%s" % (self.MARK, tcl, self.MARK))
    return value

  def quote(self, value):
    """Escape *value* for Tcl double quotes, leaving fenced expressions intact."""
    parts = value.split(self.MARK)
    out = []
    for index, part in enumerate(parts):
      if index % 2:
        out.append(part)          # a Tcl expression we inserted: keep verbatim
      else:
        out.append(re.sub(r'([\\"\[\]$])', r"\\\1", part))
    return '"%s"' % "".join(out)


def split_pathlist(value):
  return [segment for segment in value.split(os.pathsep) if segment]


def classify(name, old, new):
  """Return ('prepend'|'append'|'set', payload) for one changed variable.

  A path-list that merely grew at one end becomes prepend/append directives, so
  the module composes with whatever else the user has loaded. Anything else is
  set outright.
  """
  if not is_pathlike(name):
    return "set", new
  new_segments = split_pathlist(new)
  if old is None:
    return "prepend", new_segments
  old_segments = split_pathlist(old)
  if not old_segments:
    return "prepend", new_segments
  count = len(new_segments) - len(old_segments)
  if count > 0:
    if new_segments[count:] == old_segments:
      return "prepend", new_segments[:count]
    if new_segments[:-count] == old_segments:
      return "append", new_segments[-count:]
  return "set", new


def build_rewriter(before, pkg_root, install_root, shell_id, workdir, arch):
  """Collect path->Tcl rules for this package's root and for dependency roots.

  A dependency root is expressed relative to BASEDIR -- NOT as
  $::env(<DEP>_ROOT). That variable only exists if the dependency's module has
  been loaded, and a package's own env:/prepend_path: may legitimately reference
  a BUILD-time dependency, which the runtime modulefile never loads (CMSSW
  refers to cms-common this way). Tcl raises a hard "no such variable" error on
  the missing env entry, which aborts the whole load.

  Every package lives under the same BASEDIR, so <family>/<name>/<verrev> is
  derivable from the path itself. That is both relocation-safe and always
  defined, regardless of what else is loaded.
  """
  rules = [(pkg_root, "$%s_ROOT" % shell_id)]
  # The staging INSTALLROOT should not appear in a resolved value -- init.sh
  # points at the final location -- but map it too so a recipe that exported a
  # staging path cannot leak one.
  if install_root and install_root != pkg_root:
    rules.append((install_root, "$%s_ROOT" % shell_id))

  # Anything else under <workdir>/<arch>/ is another package in the same tree.
  arch_prefix = posixpath.join(workdir, arch) + "/"
  for name, value in before.items():
    if not name.endswith("_ROOT") or name == "%s_ROOT" % shell_id:
      continue
    if not os.path.isabs(value):
      continue
    if value.startswith(arch_prefix):
      rules.append((value, "$::env(BASEDIR)/%s" % value[len(arch_prefix):]))
    elif value.startswith(workdir + "/"):
      # architecture: share packages sit beside the arch dir, not inside it.
      rules.append((value, "$::env(BASEDIR)/../%s" % value[len(workdir) + 1:]))

  # Catch-all, deliberately last (rules are applied longest-prefix first, and
  # these are the shortest): any remaining in-tree path -- a subdirectory of a
  # dependency, or a package with no <DEP>_ROOT in scope -- still gets anchored
  # to BASEDIR rather than escaping as an absolute build path.
  rules.append((arch_prefix, "$::env(BASEDIR)/"))
  rules.append((workdir + "/", "$::env(BASEDIR)/../"))
  return PathRewriter(rules)


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--before", required=True)
  parser.add_argument("--after", required=True)
  parser.add_argument("--pkgname", required=True)
  parser.add_argument("--handwritten", default="",
                      help="a modulefile the recipe wrote itself; its lines are "
                           "appended after the generated ones so the recipe wins")
  parser.add_argument("--verrev", required=True)
  parser.add_argument("--family-segment", default="")
  parser.add_argument("--installroot", required=True)
  parser.add_argument("--workdir", required=True)
  parser.add_argument("--arch", required=True)
  parser.add_argument("--dep-modules", default="")
  parser.add_argument("--output", required=True)
  args = parser.parse_args()

  before = read_env0(args.before)
  after = read_env0(args.after)

  shell_id = re.sub(r"[^A-Za-z0-9_]", "_", args.pkgname).upper()

  # Where the package ends up once installed -- the string that must be mapped
  # back to a Tcl expression. Ground truth is <PKG>_ROOT as init.sh actually
  # resolved it; the reconstruction from PKGVERSION/PKGREVISION/PKGFAMILY is
  # only a cross-check. They disagree when the environment handed to the hook
  # does not describe the package being installed -- and a mismatch would
  # silently bake an absolute build path into the modulefile, so fail loudly
  # with the reason instead of leaving the caller's grep to find it.
  expected_root = posixpath.join(args.workdir, args.arch,
                                 args.family_segment + args.pkgname,
                                 args.verrev)
  pkg_root = after.get("%s_ROOT" % shell_id, "")
  if not pkg_root:
    sys.stderr.write(
        "generate_module: %s_ROOT is not set after sourcing init.sh -- cannot "
        "determine the package root\n" % shell_id)
    return 1
  if pkg_root != expected_root:
    sys.stderr.write(
        "generate_module: package root mismatch for %s\n"
        "  init.sh resolved : %s\n"
        "  environment says : %s\n"
        "  (check PKGVERSION/PKGREVISION/PKGFAMILY for this build)\n"
        % (args.pkgname, pkg_root, expected_root))
    return 1
  # The same location expressed relative to BASEDIR, which BASE/1.0 sets to
  # <workdir>/<arch> at load time. Purely relative segments -> relocatable.
  root_expr = "$::env(BASEDIR)/%s%s/%s" % (
      args.family_segment, args.pkgname, args.verrev)

  rewriter = build_rewriter(before, pkg_root, args.installroot, shell_id,
                            args.workdir, args.arch)

  lines = [
      "#%Module1.0",
      "#",
      "# Generated by cms.bits hooks/generate_module. Do not edit by hand.",
      "# Regenerated on every build, including cached-tarball reuse, so the",
      "# revision below is always current.",
      "#",
      "proc ModulesHelp { } {",
      '  puts stderr "CMS modulefile for %s %s"' % (args.pkgname, args.verrev),
      "}",
      'module-whatis "CMS modulefile for %s %s"' % (args.pkgname, args.verrev),
      "",
      "conflict %s" % args.pkgname,
      "",
      "# Dependencies. BASE/1.0 defines BASEDIR, so it must come first.",
      "module load BASE/1.0",
  ]
  lines.extend("module load %s" % dep for dep in args.dep_modules.split())
  lines.extend([
      "",
      "# Package root, derived at load time. No build-time path is baked in,",
      "# so this file survives relocation untouched.",
      "set %s_ROOT %s" % (shell_id, root_expr),
      "",
  ])

  # Grouped and sorted rather than emitted in environment order: the modulefile
  # ships inside the package tarball, so unstable byte order would churn
  # checksums on every rebuild for no reason, and makes diffing two builds
  # useless. Within one variable the segment order is significant and preserved.
  setenvs, prepends, appends = {}, {}, {}
  for name, new in sorted(after.items()):
    if name in SKIP_EXACT or name.startswith(SKIP_PREFIX):
      continue
    old = before.get(name)
    if old == new:
      continue
    # <PKG>_ROOT is established above as a Tcl variable; export it from there
    # rather than re-deriving it from the diff.
    if name == "%s_ROOT" % shell_id:
      setenvs[name] = ["setenv %s $%s_ROOT" % (name, shell_id)]
      continue
    kind, payload = classify(name, old, new)
    if kind == "set":
      setenvs[name] = ["setenv %s %s" % (
          name, rewriter.quote(rewriter.substitute(payload)))]
    elif kind == "prepend":
      # prepend-path pushes onto the front, so emitting the segments in reverse
      # leaves them in their original order.
      prepends[name] = [
          "prepend-path %s %s" % (
              name, rewriter.quote(rewriter.substitute(segment)))
          for segment in reversed(payload)]
    else:
      appends[name] = [
          "append-path %s %s" % (
              name, rewriter.quote(rewriter.substitute(segment)))
          for segment in payload]

  emitted = []
  # The package's own identity first, then everything else alphabetically.
  root_key = "%s_ROOT" % shell_id
  if root_key in setenvs:
    emitted.extend(setenvs.pop(root_key))
  for group in (setenvs, prepends, appends):
    for name in sorted(group):
      emitted.extend(group[name])

  if not emitted:
    lines.append("# This package contributes no environment of its own.")
  lines.extend(emitted)

  if args.handwritten and os.path.exists(args.handwritten):
    with open(args.handwritten, encoding="utf-8", errors="replace") as handle:
      # Drop the magic cookie: Tcl modulefiles carry exactly one, and ours is
      # already the first line of the file.
      kept = [line.rstrip("\n") for line in handle
              if not line.startswith("#%Module")]
    lines.extend(["", "# ---- from the recipe's own modulefile ----"] + kept)

  lines.append("")

  os.makedirs(os.path.dirname(args.output), exist_ok=True)
  with open(args.output, "w", encoding="utf-8") as handle:
    handle.write("\n".join(lines))
  return 0


if __name__ == "__main__":
  sys.exit(main())
