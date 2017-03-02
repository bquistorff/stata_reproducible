# stata_reproducible
The primary goal of this package is to make output from Stata reproducible (subsequent runs ca produce byte-identical files). This eases process of knowing if "content" changed meaningfully bewteen runs. Program driven work-flows (e.g. git) and manual checking of results are made much easier. Now output files can possibly be committed to managed by version control (helpful for storing results from long analyses).

A secondary goal is to make outputs consistent across similar versions of Stata (e.g. v13 and v14) and across different platforms. This helps if computing resources are diverse and they contribute output files (the outputs can be versioned or be in a (distributed) build cache). This secondary goal is only perfectly achievable, but workable solutions now exist.

# Usage:
If you are using Stata 13 or Stata 14 (and no others) use the same version of Stata you can:
- dta and gph: Commit them and any computer rebuild them. Use -saver-, -graph_save-, -graph_export- instead of the standard commands.
  - If using Stata 13 and 14 then use -saver ..., version(13)- and -graph_save ..., version(13)- or set DEFAULT_OUT_VERSION.
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
- eps files are different across platofrms and versions. Stata v13-win=v13-unix. Stata v13-win almost equals v14-win.
- PDFs are different across platforms and versions
- Results from numerical calculations may differ depending on Stata version, Stata flavor, OS, or architecture (e.g. x86_64). This is especially true if you use platform-specific plugins (that use compiled code). You may be able to accomodate these differences by rounding results or only outputting summaries.