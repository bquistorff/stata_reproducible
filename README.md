# stata_reproducible
Tools to make output from Stata reproducible (byte-identical). This helps with committing generated (intermediate or final) files under version control.

# Usage:
If you are using Stata 13 or Stata 14 (and no others) use the same version of Stata you can:
- dta and gph: Commit them and any computer rebuild them. Use -saver-, -graph_save-, -graph_export- instead of the standard commands.
  - If using Stata 13 and 14 then use -saver ..., version(13)- and -graph_save ..., version(13)- or set DTA_DEFAULT_VERSION and GPH_DEFAULT_VERSION.
- eps and pdf: Only build on one platform-version and commit those files. You can turn off eps/pdf exporting on certain platforms by setting $OMIT_FIG_EXPORT and using save_all_figs.ado (a project-level ado, which you can edit easily). If another platform commits new gphs, you can regenerate eps/pdf files from gph files on the main platform by using the project-level gen_ext_from_gph.do.

# Installation:
With Stata version 13 or later:
```Stata
. net install stata_reproducible, from(https://raw.github.com/bquistorff/stata_reproducible/master/) replace
```

For Stata version <13, download as zip, unzip, and then replace the above -net install- with

```Stata
. net install stata_reproducible, from(full_local_path_to_files) replace
```

## Notes
- dta and gph files are different across versions (and bit order, but if staying on Windows, Linux, and modern PC, this shouldn't be problem). You can use -, version(13)- on v14 and the files will be identical to one on v13. I've added this feature to the gph files.
- gph files are part text part binary. I convert them to have unix line endings (\n) on all platforms.
- eps files are different across platofrms and versions. Stata v13-win=v13-unix. Stata v13-win almost equals v14-win.
- PDFs are different across platforms and versions
  - v13-win uses JagPDF 1.4.0 (http://jagpdf.org) making PDF 1.5 docs
  - v14-win & v14-unix uses Haru Free PDF Library 2.4.0dev. On Unix makes PDF-1.3 and on Windows PDF-1.6.
- The fixed date is 2013-07-10 14:23:00 (random date found from another file), if you want to change that you can search for 2013 as well as datasignature_dt in -saver-.
- Results from numerical calculations may differ depending on Stata version, Stata flavor, OS, or architecture (e.g. x86_64). This is especially true if you use platform-specific plugins (that use compiled code). You may be able to accomodate these differences by rounding results or only outputting summaries.