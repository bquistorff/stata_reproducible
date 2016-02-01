# stata-reproducible
Tools to make output from Stata reproducible (byte-identical).

Currently if you use the same version of Stata you can:
-Commit dta and gph files and have any computer rebuild them.
-Commit eps and pdf files, but only make them on a specific platform

If I can convert gph v4 -> v3 then if in a project with mixed versions (13 & 14) and platforms:
-Commit dta and gph files and have any computer rebuild them (using -, version()-).
-Commit eps and pdf files, but only make them on a specific platform-version combination.

## Notes
* dta files are different across versions (and bit order, but if staying on Windows, Linux, and modern PC, this shouldn't be problem). You can use -, version(13)- on v14 and the files will be identical to one on v13. 
* gph files are different across versions
* eps files are different across platofrms and versions. Stata v13-win=v13-unix. Stata v13-win almost equals v14-win.
* PDFs are different across platforms and versions
** v13-win uses JagPDF 1.4.0 (http://jagpdf.org) making PDF 1.5 docs
** v14-win & v14-unix uses Haru Free PDF Library 2.4.0dev. On Unix makes PDF-1.3 and on Windows PDF-1.6.
* The fixed dates are 2013-07-10 14:23:00 (random date found from another file), if you want to change that you can search for 2013 as well as datasignature_dt in -saver-.