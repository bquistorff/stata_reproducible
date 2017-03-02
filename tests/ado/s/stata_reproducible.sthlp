{smcl}
{title:Reproducibility}
{pstd}
Reproducible outputs will be exactly identical (byte-for-byte) if produced again with the same code and inputs.
Most Stata outputs are not exactly reproducible so that it is not enough to tell if a file's bytes changed to know if the content changed.
It can be difficult to tell if contents changed when non-reproducible outputs, since there are no built-in tools to see if gph files are different.
Reproducible outputs make both automated and manual check of files contents easier.

{pstd}
For example, version control systems (e.g. git) and build systems that use hashes to cache build outputs (e.g. gradle) now integrate with Stata analysis.
Data outputs can now be versioned (assuming space availability) and they won't be committed. 
Manual checking of file changes is also easier.

{title:Version Control}

{title:External}

{pstd}
Reproducible builds are common concern in software development. 
See {browse "https://reproducible-builds.org/":reproducible-builds.org} for more details and {browse "https://reproducible-builds.org/docs/timestamps/":here} for specific details on SOURCE_DATE_EPOCH which is recognized by several components in this package.
