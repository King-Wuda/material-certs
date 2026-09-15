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

Type the heat number. Spaces, dashes and slashes are ignored, so `A-12 345` finds
`A12345` no matter how the mill printed it. Results are listed per page, with the
location of the file, and the page itself is previewed beside them.

*Must also contain* narrows a heat number that appears on several certs — put in the
size (`6"`), the fitting (`Elbow`), or the spec (`A234`).

**Save** writes the matching cert out as its own PDF: one file per match, all matches
merged into one file, or just the ones you tick. `keep N page(s) after each match` picks
up continuation pages when a cert runs longer than one page, and stops at the next cert
rather than swallowing it.

### Searching a whole list

The **A list of them** tab takes a column of heat numbers pasted straight from a packing
list or MTR log. It reports which ones are in the folder and which are missing, names the
file and page for each one found, and can write out one PDF per heat number — which is
most of the work of assembling a submittal.

### Scanned certs

Certs that are scans have no text layer, so there is nothing to search until the page is
read by OCR. The tool counts those pages and offers a **Read scanned pages (OCR)** button.
The OCR engine (~10 MB) is downloaded the first time it is used, and recognition takes a
few seconds per page. Everything else works without it.

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
