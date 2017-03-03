{smcl}
{* *! version 0.1.0  28feb2017}{...}
{title:Title}

{phang}
{bf:make_trk_paths} {hline 2} Converts local paths in a stata.trk file of an ado root between absolute and relative forms.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:make_trk_paths} relative, adofolder({it:string})

{p 8 17 2}
{cmdab:make_trk_paths} absolute, adofolder({it:string})

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt adofolder}}The folder where to work from. Likely the folder where new packages are installed (see {it:{help net} set ado}).{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{it:stata.trk} files are at the base of each ado directory "tree" (that has letter subfolders) and is necessary for finding packages in those subfolders. 
It records the location of where each package was installed from so that it can be updated. 
Unfortunately, local paths must be absolute rather than relative for updating to work. 
But if a project is shared across different users or accounts they may not have the same absolute path for the install files, and therefore can't have the same fully-functional {it:stata.trk} files. 
The solution this tool solves, is to normally keep relative paths for local sources of packages, and then to temporarily convert them to absolute paths only when updating is necessary.

{marker remarks}{...}
{title:Remarks}
{phang}
Trying to update packages with a relative path stored in the stata.trk fails when using either {it:adoupdate} or {it:net install ..., replace}. 
{it:adoupdate} will call {it:net install} and then silently fail (it doesn't even set _rc). 
{it:net install, replace} will pollute the {stata.trk} file with a nearly identical entry (since paths don't match) and this can cause problems for tools later. 
Note that none of {it:net (describe|from|get|install)} commands accept relative paths.

{phang}
Note that sometimes the package indexes (U counters) may change in the {it:stata.trk} file, but this is fine to sync across users of a shared project.

{marker examples}{...}
{title:Examples}

{pstd}
Install a new package from a local source (if has platform-specific files, use {help adostorer}).

{phang}{cmd:. net install {it:package}, from({it:package_src_absolute_path})}{p_end}
{phang}{cmd:. make_trk_paths relative, adofolder({it:adofolder})}{p_end}

{pstd}
Update packages installed from a local source (could alternatively uninstall, and then reinstall as above).
If the package has platform-specific files, use {help adostorer}. 

{phang}{cmd:. make_trk_paths absolute, adofolder({it:adofolder})}{p_end}
{phang}{cmd:. adoupdate {it:package}, update}{p_end}
{phang}{cmd:. make_trk_paths relative, adofolder({it:adofolder})}{p_end}

