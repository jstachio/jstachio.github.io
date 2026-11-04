#!/usr/bin/env bash
# Writes index.html listing every released version of the Rainbow Gum documentation
# in this directory, newest first. A version is a directory named like 0.17.0 that has
# apidocs/index.html. The version the current symlink points to is marked current.
# The date is when the version was first committed here, or today for a version that
# is not committed yet, as right after build.sh.
set -euo pipefail

cd "$(dirname "$0")"

_current=$(readlink current 2>/dev/null || true)
_today=$(date +%F)

_rows=""
for _version in $(ls -d [0-9]*.[0-9]*.[0-9]* 2>/dev/null | sort -V -r); do
	if ! [[ "$_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || [ ! -f "$_version/apidocs/index.html" ]; then
		continue
	fi
	_date=$(git log --diff-filter=A --format=%ad --date=short -- "$_version/apidocs/index.html" 2>/dev/null | tail -1)
	_date=${_date:-$_today}
	_class=""
	_badge=""
	if [ "$_version" = "$_current" ]; then
		_class=' class="current"'
		_badge=' <span class="badge">current</span>'
	fi
	_rows+="        <tr${_class}>
          <td class=\"version\"><a href=\"${_version}/apidocs/\">${_version}/</a>${_badge}</td>
          <td class=\"date\">${_date}</td>
          <td class=\"source\"><a href=\"https://github.com/jstachio/rainbowgum/tree/v${_version}\">v${_version}</a></td>
        </tr>
"
done

if [ -z "$_rows" ]; then
	echo "No versions found in $(pwd)" >&2
	exit 1
fi

cat > index.html <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Rainbow Gum documentation</title>
  <style>
    :root {
      --bg: #fbfaf7;
      --fg: #22201c;
      --muted: #6b665d;
      --line: #e4e0d8;
      --link: #0b63a8;
      --row: #f3f0ea;
      --badge-bg: #007ec6;
      --badge-fg: #ffffff;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #17181a;
        --fg: #e6e3dd;
        --muted: #9a958c;
        --line: #2c2e31;
        --link: #6cb6f0;
        --row: #202225;
      }
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--fg);
      font: 15px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif;
    }
    .bark {
      height: 6px;
      background: linear-gradient(90deg, #4f8a3b, #2f8f8a, #3c6fb6, #7b4ea3, #c0563b, #d9902b);
    }
    main { max-width: 720px; margin: 0 auto; padding: 32px 16px 48px; }
    h1 { font-size: 1.5rem; margin: 0 0 4px; }
    p { margin: 0 0 24px; color: var(--muted); }
    a { color: var(--link); text-decoration: none; }
    a:hover, a:focus-visible { text-decoration: underline; }
    table { width: 100%; border-collapse: collapse; font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; font-size: 14px; }
    th {
      text-align: left;
      font-weight: 600;
      color: var(--muted);
      font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
      font-size: 12px;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      border-bottom: 1px solid var(--line);
      padding: 8px 12px;
    }
    td { padding: 8px 12px; border-bottom: 1px solid var(--line); white-space: nowrap; }
    tr.current td { background: var(--row); }
    td.date, td.source { color: var(--muted); font-variant-numeric: tabular-nums; }
    .badge {
      display: inline-block;
      margin-left: 8px;
      padding: 0 6px;
      border-radius: 3px;
      background: var(--badge-bg);
      color: var(--badge-fg);
      font: 600 11px/18px system-ui, -apple-system, "Segoe UI", sans-serif;
      vertical-align: 1px;
    }
    .wrap { overflow-x: auto; }
  </style>
</head>
<body>
  <div class="bark"></div>
  <main>
    <h1>Rainbow Gum documentation</h1>
    <p>User guide and javadoc for each release. The <a href="https://jstach.io/rainbowgum/">latest snapshot</a>
    is built from main, and the <a href="https://github.com/jstachio/rainbowgum">source</a> is on GitHub.</p>
    <div class="wrap">
    <table>
      <thead>
        <tr><th>Version</th><th>Published</th><th>Source</th></tr>
      </thead>
      <tbody>
${_rows}      </tbody>
    </table>
    </div>
  </main>
</body>
</html>
EOF

echo "Wrote $(pwd)/index.html"
