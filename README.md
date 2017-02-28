# PDFexploder

This utility can "explode" large PDFs into numerous smaller fragments
(files) based on a CSV-formatted index file which defines the names
and starting/ending pages of each section fragment.  The section
fragments are each extracted by invoking
[`pdfjam`](http://www2.warwick.ac.uk/fac/sci/statistics/staff/academic-research/firth/software/pdfjam/),
and the resulting files are named in a way which makes their source document and originating page numbers clear.

Additionally, [LaTeX](https://www.latex-project.org/) is used to
generate an index PDF which lists all the section fragments as
hyperlinks, for ease of navigation.  This index is typically built
from the [`index.latex.erb` template](index.latex.erb) but you can
use any LaTeX template written in [eRuby](https://en.wikipedia.org/wiki/ERuby)
(`.erb`) file syntax.

## Usage

    ./bin/build.rb CSV LATEX-TEMPLATE PDF-DIR INDEX-DIR OUTPUT-DIR

See https://github.com/aspiers/book-indices for an example of how to
write the CSV index files.

## Similar software

- https://git.zx2c4.com/realbook-splitter/tree/
- http://www.pdfsam.org/pdfsam-basic/

Please [edit this file and then submit a pull request](https://github.com/aspiers/PDFexploder/edit/master/README.md)
if you know of any other similar software - thanks!
