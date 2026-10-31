#!/usr/bin/env bash
# Local/manual equivalent of the scheduled upstream source check.
set -euo pipefail

branch="$(sed -n 's/^- Upstream branch at import time: `\(.*\)`$/\1/p' GTOR_SOURCE.md)"
if [[ -z "$branch" ]]; then
  echo "Could not read the tracked Tor Browser branch from GTOR_SOURCE.md" >&2
  exit 1
fi

git submodule update --init --depth 1 -- upstream/tor-browser
git -C upstream/tor-browser fetch --depth=1 origin "refs/heads/$branch"
git -C upstream/tor-browser checkout --detach FETCH_HEAD

old_pin="$(git ls-tree HEAD upstream/tor-browser | awk '{print $3}')"
new_pin="$(git -C upstream/tor-browser rev-parse HEAD)"
if [[ "$old_pin" == "$new_pin" ]]; then
  echo "Already current: $new_pin"
  exit 0
fi

python3 - "$new_pin" <<'PY'
from datetime import datetime, timezone
from pathlib import Path
import re
import sys

pin = sys.argv[1]
path = Path("GTOR_SOURCE.md")
content = path.read_text()
content, count = re.subn(
    r"(?m)^- Pinned upstream commit: `[0-9a-f]{40}`$",
    f"- Pinned upstream commit: `{pin}`",
    content,
    count=1,
)
if count != 1:
    raise SystemExit("Could not update exactly one pinned-commit entry")
content, count = re.subn(
    r"(?m)^- Source checkout date: .*?$",
    f"- Source checkout date: {datetime.now(timezone.utc).date().isoformat()}",
    content,
    count=1,
)
if count != 1:
    raise SystemExit("Could not update exactly one source-checkout date")
path.write_text(content)
PY

git add upstream/tor-browser GTOR_SOURCE.md
git commit -m "chore: update pinned Tor Browser source"
echo "Updated source pin from $old_pin to $new_pin."
echo "Review and push this commit through a pull request; do not force-push main."
