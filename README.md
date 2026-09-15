# Heat Number Search

A single-page tool for finding a heat number across a pile of material test reports and
pulling the matching certificate out as its own PDF.

Put `heat-search.html` in the folder with the certs and open it. It reads every PDF in
that folder and everything under it, and every result tells you which file the heat
number is in and what page it is on.

Everything runs in the browser. The PDFs are never uploaded anywhere — they are read in
the page itself, so it is safe to use with customer documents.

## Getting the folder in

Browsers are not allowed to read the disk on their own, so there are three ways in. The
tool tries them in this order:

1. **Automatic — run `scan-certs.bat`** (Windows; `scan-certs.sh` on Mac and Linux).
   It serves the folder it sits in and opens the page, and the page then walks the whole
   folder tree by itself: no clicks, subfolders included. Needs Python installed, which
   is the only reason the other two exist.
2. **Scan a folder** — Chrome and Edge let the page keep a folder, so the next visit
   offers *Open &lt;folder&gt; again* and reloads it in one click. **Rescan** picks up certs
   that have been added since.
3. **Drop PDFs on the page**, or click to choose files. Works in every browser, and is
   the quickest way to search one package you have just been sent.

Whichever way they arrive, up to 400 PDFs are read, six folders deep. Files that are
already loaded are skipped, so a rescan only costs time for what is new. A cert that
cannot be read — damaged, password protected, or still in the cloud with no connection —
is named in a notice and the rest of the scan carries on without it.

### OneDrive, SharePoint and network drives

A synced OneDrive folder is an ordinary folder on disk, so all three options work from
inside one. Two things to know:

- **Files On-Demand.** A cert that shows in Explorer may not actually be on the machine.
  Reading it pulls it down, so the first scan of a large cloud-only folder is slow and
  needs a connection; without one, those files are skipped and listed. Right-click the
  folder and choose *Always keep on this device* before scanning a big package.
- **`scan-certs.bat` may be blocked** when Windows sees it came from the internet.
  Right-click it, choose Properties, tick *Unblock*, or use the *Scan a folder* button
  instead.

Files that live only in the OneDrive or SharePoint website, with nothing synced to the
machine, cannot be reached — sync the folder or download the PDFs first.

## Searching

**The heat number is matched against the HEAT column.** The tool finds the heading on
each page — `HEAT No.`, `HEAT`, `HEAT NUMBER`, `Heat No:` and the like — and matches the
values listed under it, or written beside it. So a number that appears on a page as a
purchase order, a chemistry figure, a heat-treatment lot, or in a `LOT No.` column is no
longer a hit. `HEAT TREATMENT` and `HEAT ANALYSIS` headings are ignored, since neither
holds heat numbers. Each result shows the heading it matched under and the exact value:
`HEAT No. → 5A1234`.

Spaces, dashes and slashes are ignored, so `A-12 345` finds `A12345` no matter how the
mill printed it, and a mill's suffix is allowed — searching `A12345` still finds
`A12345-1`.

If nothing is found in a HEAT column, the pages that mention the number elsewhere are
shown instead, each marked *not in a HEAT column*, with a line saying why. Tick **Match
the heat number anywhere on the page** to search the old way — useful for a mill that
labels the column something else entirely.

### Words and phrases

The second box takes words that must also be on the page:

    con reducer 50x40          every word must appear
    "con reducer" 50x40        the quoted words must appear together

Both boxes work on their own. Leave the heat number empty and search `"con reducer"
50x40` to find every cert for that fitting; fill both in to pin one cert down. Words are
matched anywhere on the page, and ignore punctuation the same way, so `50x40` finds
`50 X 40` and `"con reducer"` finds `CON. REDUCER`.

### Reading and saving what it finds

The preview beside the results shows the matching page. **Full screen** — or the `F` key
— gives it the whole window: `+` and `−` zoom in on the small print, **Fit** returns to
the whole page, the arrow keys turn pages, and `Esc` closes it.

**Save** writes the cert out as its own PDF: one file per match, every match merged into
one file, or just the ones you tick. `keep N page(s) after each match` picks up
continuation pages when a cert runs longer than one page, and stops at the next cert
rather than swallowing it.

### Searching a whole list

The **A list of them** tab takes a column of heat numbers pasted straight from a packing
list or MTR log. It reports which ones are in the folder and which are missing, names the
file and page for each one found, and can write out one PDF per heat number — which is
most of the work of assembling a submittal.

### Certs that were scanned on a printer

Most office printers OCR a page as they scan it and embed the result in the PDF. That
text is often wrong — `5A1234` comes out as `SA12E4`, `B78890` as `B7BB9O` — and because
the page *has* text, nothing looks amiss until a search finds the wrong cert, or none.

So the tool decides what is a scan by looking at the page, not at whether it has text: a
page covered by a full-page image is a scan, and its text is read again from the image
with Tesseract, replacing whatever the scanner put there. That happens automatically while
the folder is being read, and every page read is remembered against the file it came from,
so a cert is only ever read once, however often the page is reloaded. **Stop** halts a long
run; the button in the notice picks up whatever is left.

Reading a scanned page takes a second or two, so the first pass over a folder of scans is
slow. Two things make it bearable: it only happens once, and search works on the certs
already read while the rest are still going.

If a scan is poor enough that OCR still misreads a heat number, a search for the real
number will match a value that differs only in the characters OCR confuses — `O/0`, `I/1`,
`S/5`, `B/8`, `Z/2`, `G/6` — and label it **OCR near match** so it is never mistaken for a
certain one.

### Doing the OCR once, up front

For a whole archive, `ocr-certs.bat` (`ocr-certs.sh` on Mac and Linux) is faster and more
accurate than reading scans in the browser. It runs [OCRmyPDF](https://ocrmypdf.readthedocs.io)
over every PDF under the folder it sits in and writes searchable copies to a folder named
`<that folder>-ocr`, leaving the originals untouched. Point `heat-search.html` at the new
folder and searches are instant, with no OCR in the browser at all.

It needs OCRmyPDF installed once (`pip install ocrmypdf`, plus Tesseract and Ghostscript).
The run is incremental — certs already converted are skipped — and a file OCRmyPDF cannot
read is copied across unchanged rather than lost.

## Notes

- **First run needs internet.** The PDF engine (pdf.js), the PDF writer (pdf-lib) and the
  OCR engine are loaded from public CDNs, then cached by the browser. To run it somewhere
  with no internet at all, save those files next to `heat-search.html` and point the
  `<script>` tags and the `TESS_*` paths at the local copies.
- **Don't rename it to `index.html`.** A web server hands out `index.html` instead of the
  folder listing, and the page would no longer be able to see what is in the folder.
- **Performance.** A 250-page package indexes in about ten seconds, and searches after
  that are instant. Serving the folder (option 1) is also the faster way to read large
  packages, because pdf.js can then use a background worker.
- **Browsers.** Chrome, Edge and Firefox. No install, no Python for options 2 and 3, and
  no Tesseract or Poppler folder to keep beside an executable.

## Background

This replaces a Tkinter desktop tool (`pdf_searcher.py`) that needed Python plus bundled
Tesseract and Poppler binaries to run. Same job — walk a folder of certs, match on heat
number, tell me where it is — with a preview of the page before you save it, and the
matching cert extracted as a new PDF.
