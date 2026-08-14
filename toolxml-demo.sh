package: toolxml-demo
version: vCMS
variables:
 cms: '20'
requires:
 - gcc
---
# Demo package: generates SCRAM tool-config xml for every package in this
# recipe's own `requires:` list (and their transitive dependency closure),
# using the parallel/explicit-dependency toolxml generator instead of the
# real pipeline's serial shell-sourcing. Writes into this package's own
# real $INSTALLROOT -- add more packages to requires: above to widen it.
export TOOLXML_OUTPUT_DIR="$INSTALLROOT"
export TOOLXML_SCRAM_TOOLS_DIR="/data/akd/scram-tools-fork"
export PYTHONPATH="/data/akd/bits/.claude/worktrees/toolxml-plugin-draft"

python3 /data/akd/bits/.claude/worktrees/toolxml-plugin-draft/bits_helpers/toolxml/validate.py $REQUIRES

echo "toolxml-demo: wrote output to $INSTALLROOT"
ls "$INST LLROOT/selected" 2>/dev/null | wc -l
