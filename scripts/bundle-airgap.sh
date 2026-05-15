#!/usr/bin/env bash
# Bundle the Neovim config + plugins + Mason tools + treesitter parsers
# into a single tarball for deployment to an air-gapped Linux x86_64 VM.
#
# Reads version from CHANGELOG.md, stages assets in /tmp, flips
# vim.g.airgapped=true in the bundled copy, generates RESTORE.md from
# RESTORE.template.md, and emits bundles/nvim-airgapped-bundle-<version>.tar.gz.
#
# Usage:  scripts/bundle-airgap.sh
#         (run from anywhere; the script resolves its own paths)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$SCRIPT_DIR/RESTORE.template.md"

err()  { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARNING: $*" >&2; }
info() { echo "==> $*"; }

# --- Step 1: read version from CHANGELOG.md ---------------------------------
VERSION="$(grep -m1 -oP '^## v\K[0-9]+\.[0-9]+\.[0-9]+' "$REPO_ROOT/CHANGELOG.md" || true)"
[[ -n "$VERSION" ]] || err "Could not find a '## v<version>' line in CHANGELOG.md"
info "Bundling version $VERSION..."

BUNDLE_NAME="nvim-airgapped-bundle-$VERSION"
STAGING="/tmp/$BUNDLE_NAME"
BUNDLES_DIR="$REPO_ROOT/bundles"
OUTPUT="$BUNDLES_DIR/$BUNDLE_NAME.tar.gz"

# --- Step 2: pre-flight -----------------------------------------------------
mkdir -p "$BUNDLES_DIR"
[[ -f "$OUTPUT" ]] && warn "$OUTPUT already exists — it will be overwritten."

# Wipe any leftover staging dir from a prior aborted run
rm -rf "$STAGING"

# --- Step 3: create staging layout ------------------------------------------
info "Creating staging directory at $STAGING"
mkdir -p "$STAGING/config" \
         "$STAGING/data/site/pack/core" \
         "$STAGING/data/site/parser" \
         "$STAGING/data/site/queries" \
         "$STAGING/data/site/k8s-schemas"
# data/mason is created by the cp in step 8 — avoids accidental nesting.

# --- Step 4: copy Neovim config ---------------------------------------------
info "Copying Neovim config..."
cp -r "$REPO_ROOT" "$STAGING/config/nvim"
rm -rf "$STAGING/config/nvim/bundles"

# Verify required offline binaries are present in dist/
DIST="$STAGING/config/nvim/dist"
for required in "nvim-linux-x86_64.tar.gz" "tree-sitter-cli-linux-x86.zip"; do
    [[ -f "$DIST/$required" ]] || err "Missing $DIST/$required — re-stage dist/ before bundling."
done
compgen -G "$DIST/lazygit_*_linux_x86_64.tar.gz" >/dev/null \
    || err "Missing $DIST/lazygit_*_linux_x86_64.tar.gz — re-stage dist/ before bundling."

# --- Step 5: flip airgapped=true --------------------------------------------
info "Flipping vim.g.airgapped to true in bundled copy..."
sed -i 's/vim\.g\.airgapped = false/vim.g.airgapped = true/' "$STAGING/config/nvim/init.lua"
grep -qE "^[[:space:]]*vim\.g\.airgapped = true" "$STAGING/config/nvim/init.lua" \
    || err "Failed to flip vim.g.airgapped — inspect $STAGING/config/nvim/init.lua"

# --- Step 6: copy plugins ---------------------------------------------------
info "Copying plugins..."
PLUGIN_SRC="$HOME/.local/share/nvim/site/pack/core/opt"
[[ -d "$PLUGIN_SRC" ]] || err "Plugin dir not found: $PLUGIN_SRC"
cp -r "$PLUGIN_SRC" "$STAGING/data/site/pack/core/"

# --- Step 7: copy treesitter parsers ----------------------------------------
info "Copying treesitter parsers..."
PARSER_SRC="$HOME/.local/share/nvim/site/parser"
[[ -d "$PARSER_SRC" ]] || err "Parser dir not found: $PARSER_SRC"
shopt -s nullglob
parsers=("$PARSER_SRC"/*.so)
shopt -u nullglob
[[ ${#parsers[@]} -gt 0 ]] || err "No .so parsers found in $PARSER_SRC"
cp "${parsers[@]}" "$STAGING/data/site/parser/"

# --- Step 7b: copy treesitter queries ---------------------------------------
# nvim-treesitter (main branch) installs per-language highlight/indent/fold
# queries to ~/.local/share/nvim/site/queries/<lang>/. Without these the
# parser loads but vim.treesitter.query.get() returns nil and nothing is
# highlighted.
info "Copying treesitter queries..."
QUERIES_SRC="$HOME/.local/share/nvim/site/queries"
[[ -d "$QUERIES_SRC" ]] || err "Queries dir not found: $QUERIES_SRC — run :TSInstall for each language online first."
cp -rL "$QUERIES_SRC"/. "$STAGING/data/site/queries/"

# --- Step 7c: copy Kubernetes JSON schemas ----------------------------------
# yamlls's SchemaStore catalog points at GitHub-hosted k8s schemas (yannh's
# kubernetes-json-schema). In airgap those fetches fail; we ship the schema
# locally and the init.lua yamlls config points yaml.schemas at file:// paths
# under ~/.local/share/nvim/site/k8s-schemas/.
info "Copying Kubernetes JSON schemas..."
K8S_SCHEMAS_SRC="$REPO_ROOT/dist/k8s-schemas"
[[ -d "$K8S_SCHEMAS_SRC" ]] || err "k8s schemas dir not found: $K8S_SCHEMAS_SRC"
cp -r "$K8S_SCHEMAS_SRC"/. "$STAGING/data/site/k8s-schemas/"

# --- Step 8: copy Mason tools -----------------------------------------------
info "Copying Mason tools..."
MASON_SRC="$HOME/.local/share/nvim/mason"
[[ -d "$MASON_SRC" ]] || err "Mason dir not found: $MASON_SRC"
cp -r "$MASON_SRC" "$STAGING/data/"
rm -rf "$STAGING/data/mason/staging"

# --- Step 9: generate RESTORE.md from template ------------------------------
info "Generating RESTORE.md..."
[[ -f "$TEMPLATE" ]] || err "Template not found: $TEMPLATE"
sed "s/__VERSION__/$VERSION/g" "$TEMPLATE" > "$STAGING/RESTORE.md"

# --- Step 10: tar it up -----------------------------------------------------
info "Creating tarball..."
tar -czf "$OUTPUT" -C /tmp "$BUNDLE_NAME"

# --- Step 11: clean up staging ----------------------------------------------
info "Cleaning up staging dir..."
rm -rf "$STAGING"

# --- Step 12: report --------------------------------------------------------
SIZE=$(du -h "$OUTPUT" | cut -f1)
PLUGIN_COUNT=$(tar -tzf "$OUTPUT" | grep -cE "data/site/pack/core/opt/[^/]+/$" || true)
PARSER_COUNT=$(tar -tzf "$OUTPUT" | grep -cE "data/site/parser/[^/]+\.so$" || true)
QUERIES_COUNT=$(tar -tzf "$OUTPUT" | grep -cE "data/site/queries/[^/]+/$" || true)
SCHEMA_COUNT=$(tar -tzf "$OUTPUT"  | grep -cE "data/site/k8s-schemas/[^/]+/$" || true)
MASON_COUNT=$(tar -tzf "$OUTPUT"  | grep -cE "data/mason/packages/[^/]+/$" || true)

cat <<EOF

Bundle created successfully.

  Path:     $OUTPUT
  Size:     $SIZE
  Version:  $VERSION
  Plugins:  $PLUGIN_COUNT
  Parsers:  $PARSER_COUNT
  Queries:  $QUERIES_COUNT languages
  Schemas:  $SCHEMA_COUNT k8s versions
  Mason:    $MASON_COUNT tools

Transfer the tarball to the air-gapped VM and follow RESTORE.md inside the archive.
EOF
