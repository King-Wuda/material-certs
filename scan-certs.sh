#!/bin/sh
# Serves this folder so heat-search.html can find the PDFs in it by itself.
# Put this file next to heat-search.html, in the folder with the certificates.
cd "$(dirname "$0")" || exit 1
PORT=8752
URL="http://localhost:$PORT/heat-search.html"

open_browser() {
  sleep 1
  if command -v open >/dev/null 2>&1; then open "$URL"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$URL"
  else echo "Open $URL in your browser."
  fi
}

if command -v python3 >/dev/null 2>&1; then
  echo "Serving this folder at http://localhost:$PORT/ - press Ctrl+C when you are done."
  open_browser &
  exec python3 -m http.server "$PORT"
fi

echo "Python was not found, so the page cannot read this folder on its own."
echo "Open heat-search.html and use the \"Scan a folder\" button instead."
