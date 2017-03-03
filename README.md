# stata_reproducible
The primary goal of this package is to allow output from Stata to be perfectly reproducible (subsequent runs producing byte-identical files). This is not normally the case as often files contain time/date information and randomness. With reproducible output, checking if "real" content changed can be done by see if just the files bytes are the same (no need to smartly inspect files). Program driven work-flows (e.g. git, gradle's build cache) and manual checking of results are made much easier. 

Reproducibility can be defined narrowly as being able to produce the same outputs later on the exact same machine, code, and input. More broadly, though, reproducibility allows someone with a slightly different setup to produce the exact same setup. The tools in this package allow almost all outputs to be machine-specific reproducible. These tools also help with machine-agnostic reproducibility. This later part is helpful if the same project is being run on multiple systems (e.g. by collaborators with different setups). The tools do this by (a) allowing easy storage and management of package dependencies that have platform specific files, (b) allowing some formats to be saved in earlier versions so that multiple versions of Stata can produce the same output, (c) normalizing some file types across platforms.

Using these tools it is possible for contributors on Windows and Linux using either Stata 13 or 14 to work out of the same git repository and version log, dta, and gph files (which allows easy checking if results change and saves outputs from long-running analyses). Graph exported image formats are narrowly reproducible but not across setups, but tools can be accomodated so that only one type of machine needs to re-export these (not very time-consuming and can be automated).

# Usage:
The main set of tools are programs that replace built-in file-generation commands. Use, for instance, `saver` instead of `save`, `log_closer` instead of `log close`, and `graph_saver` instead of `graph save` for reproducibility between Windows and Linux. Set `global DEFAULT_OUT_VERSION=13` if you use both Stata 13 and 14 and wish the dta and gph files to always be saved in version 13's formats. Use `graph_exportr` instead of `graph export` to enable machine-specific reproducibility for most image formats. If you have multiple platforms or versions working in a version control system, you can either version these outputs but only have one system generate them (it could have a dedicated task of exporting the gph files to commonly used formats) or unversion them and have each user generate them as needed (again with the above gph->fmt program). See `help graph_export` for details.

Part of reproducibility is keeping track of package dendencies. It is a good idea to store them with your project as packages change and cause breakages and it can be hard to get old versions. But if theses packages have machine-specific files this can cause problems. This package includes the tools `adostorer`, `make_trk_paths`, and `platformname` to help manage these (see `adostorer`'s help).

# Installation:
With Stata version 13 or later:
```Stata
. net install stata_reproducible, from(https://raw.github.com/bquistorff/stata_reproducible/master/) replace
```

For Stata version <13, download as zip, unzip, and then replace the above -net install- with

```Stata
. net install stata_reproducible, from(full_local_path_to_files) replace
```

## Remarks
- I am only able to test reproducbility on Windows and Linux with versions 13 and 14. Because of this I am unable to test (or make conversions around) machines with hilo byte orders. 
- Results from numerical calculations may differ depending on Stata version, Stata flavor, OS, or architecture (e.g. x86_64). This is especially true if you use platform-specific plugins (that use compiled code). You may be able to accomodate these differences by rounding results or only outputting summaries.
- While in general the exported image formats are different across versions and platforms (so they are generally all unique) it does seem to be true that for eps files that version 13 produces identical files on Windows and Linux.
- Reproducible builds are a common concern in software development. 
See [reproducible-builds.org](https://reproducible-builds.org/) for more details and [here](https://reproducible-builds.org/docs/timestamps/) for specific details on SOURCE_DATE_EPOCH which is recognized by several components in this package.