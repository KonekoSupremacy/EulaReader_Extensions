#!/usr/bin/env bash
# local release, no CI needed
# usage: ./release.sh "short commit summary" [--no-push]
set -euo pipefail

msg="${1:?commit summary}"
repo="$(cd "$(dirname "$0")" && pwd)"
src="${EULA_EXT_SRC:-$repo/../EulaReader_Extensions_Source}"
export USER_CONTENT_BASE="https://raw.githubusercontent.com/KonekoSupremacy/EulaReader_Extensions/main"

(cd "$src" && rm -rf .js .dist && npm run build:full)

# same layout as upstream lnreader-plugins, app reads .dist/plugins.min.json
rm -rf "$repo/.dist" "$repo/.js" "$repo/public"
mkdir -p "$repo/.js/src" "$repo/public"
cp -r "$src/.dist" "$repo/.dist"
cp -r "$src/.js/plugins" "$repo/.js/src/plugins"
cp -r "$src/public/static" "$repo/public/static"
cp "$src/total.svg" "$repo/total.svg"

cd "$repo"
git add -A .dist .js public total.svg
git commit -q -m "$msg"
[ "${2:-}" = "--no-push" ] || git push origin HEAD
echo "published $(python -c "import json;print(len(json.load(open('.dist/plugins.min.json',encoding='utf-8'))))") plugins"
