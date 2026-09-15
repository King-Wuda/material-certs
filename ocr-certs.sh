#!/bin/sh
# Bakes a proper text layer into every PDF under this folder, once.
# Originals are never touched: searchable copies go to a folder named <this folder>-ocr.
cd "$(dirname "$0")" || exit 1
SRC="$PWD"
DST="$PWD-ocr"

if ! command -v ocrmypdf >/dev/null 2>&1; then
  echo "ocrmypdf was not found."
  echo "Install it once:   pip install ocrmypdf"
  echo "It also needs Tesseract and Ghostscript -- see"
  echo "https://ocrmypdf.readthedocs.io/en/latest/installation.html"
  exit 1
fi

echo "Reading every PDF under  $SRC"
echo "Writing searchable copies to  $DST"
echo

find "$SRC" -type f -iname '*.pdf' | sort | while IFS= read -r f; do
  rel=${f#"$SRC"/}
  out="$DST/$rel"
  if [ -f "$out" ]; then
    echo "  skipping $rel (already done)"
    continue
  fi
  mkdir -p "$(dirname "$out")"
  printf '  %s\n' "$rel"
  # --redo-ocr throws away the scanner's own OCR and reads the page properly,
  # while leaving any genuine text in the file alone.
  if ocrmypdf --redo-ocr --deskew --rotate-pages --language eng \
              --output-type pdf --quiet "$f" "$out"; then
    :
  else
    echo "      could not be read -- copying the original unchanged"
    cp "$f" "$out"
  fi
done

echo
echo "Finished. Point heat-search.html at  $DST"
