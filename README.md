# Heat Number Search

A single-page tool for pulling a material test report out of a combined certificate PDF.

Open `index.html` in a browser, drop in the cert package, type a heat number, and save
the matching cert as its own PDF.

Everything runs in the browser. The PDFs are never uploaded anywhere — they are read
in the page itself, so it is safe to use with customer documents.

## Using it

1. **Load certificates** — drag one combined PDF (or several files) onto the drop area.
   Each page is read and indexed; the progress bar shows where it is.
2. **Search** — type the heat number. Spaces, dashes and slashes are ignored, so
   `A-12 345` finds `A12345` no matter how the mill printed it. *Must also contain*
   narrows a heat number that shows up on several certs — put in the size (`6"`), the
   fitting (`Elbow`), or the spec (`A234`).
3. **Save** — every match can be saved as its own PDF, or all of them merged into one
   file. `keep N page(s) after each match` picks up continuation pages when a cert runs
   longer than a page.

### Searching a whole list

The **A list of them** tab takes a column of heat numbers pasted straight from a packing
list or MTR log. It reports which ones are in the package and which are missing, and can
write out one PDF per heat number — which is most of the work of assembling a submittal.

### Scanned certs

Certs that are scans have no text layer, so there is nothing to search until the page is
read by OCR. The tool counts those pages and offers a **Read scanned pages (OCR)** button.
The OCR engine (~10 MB) is downloaded the first time it is used, and recognition takes a
few seconds per page. Everything else works without it.

## Notes

- **First run needs internet.** The PDF engine (pdf.js), the PDF writer (pdf-lib) and the
  OCR engine are loaded from public CDNs, then cached by the browser. To run it somewhere
  with no internet at all, save those files next to `index.html` and point the `<script>`
  tags and the `TESS_*` paths at the local copies.
- **Performance.** Serving the file (`python -m http.server`, then open
  <http://localhost:8000/index.html>) lets pdf.js use a background worker and index large
  packages faster. Opening the file directly with a double-click also works — pdf.js falls
  back to reading on the main thread. A 250-page package indexes in roughly 10 seconds that
  way, and searches after that are instant.
- **Browsers.** Chrome, Edge and Firefox. No install, no Python, no Tesseract or Poppler
  folder to keep next to the executable.

## Background

This replaces a Tkinter desktop tool (`pdf_searcher.py`) that needed Python plus bundled
Tesseract and Poppler binaries to run. Same idea, but it searches inside one combined
package, previews the page before saving, and extracts the matching cert as a new PDF.
