{smcl}
{* *! version 0.1.0  28feb2017}{...}
{viewerjumpto "Syntax" "adostorer##syntax"}{...}
{viewerjumpto "Description" "adostorer##description"}{...}
{viewerjumpto "Remarks" "adostorer##remarks"}{...}
{viewerjumpto "Examples" "adostorer##examples"}{...}
{title:Title}

{phang}
{bf:adostorer} {hline 2} installs packages to a directory in a way that all platforms can use the same shared directory.

{marker syntax}{...}
{title:Syntax}

The three main commands are

{p 8 17 2}
{cmdab:adostorer}
install {it:package}
{cmd:,} {cmd:{opt adofolder}(}{it:string}{cmd:)} [{cmd:replace} {cmd:all} {cmd:{opt from}(}{it:string}{cmd:)} {cmd:mkdirs}]

{p 8 17 2}
{cmdab:adostorer}
uninstall {it:package}
{cmd:,} {cmd:{opt adofolder}(}{it:string}{cmd:)}

{p 8 17 2}
{cmdab:adostorer}
update {it:pkglist}
{cmd:,} {cmd:{opt adofolder}(}{it:string}{cmd:)} [{cmd:mkdirs}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt adofolder}}The folder where to work from.{p_end}
{syntab:Install}
{synopt:{opt replace}}Replace existing installation files.{p_end}
{synopt:{opt all}}Install all files including ancillary ones.{p_end}
{synopt:{opt from}({it:string})}Where to install from. If not specified, then SSC is assumed.{p_end}
{synopt:{opt mkdirs}}Create platformname name directories as necessary.{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
For reproducible research it is helpful to store packages in project folders.
It is hard to get historical versions of packages (e.g. SSC doesn't keep track of old versions)
so storing a copy of packages ensures that analyses can be re-run in the future even if packages change.
If a project folder is shared across different platforms (e.g. it is in a version 
controls sytem such as {it:git}), then this causes a problem. 
Packages with platform-specific files normally get mapped to the same location on different platforms
cause one platform's version to overwrite anothers. 
{cmd:adostorer} solves this problem by saving platform-specific files to new platform-specific folders 
(e.g. {it:WIN64A} for 64 bit Windows) and then re-writing the {it:stata.trk} files to
point to the new locations. Stata sessions then only need to add their platform's folder
to the ado-path using the included {help platformname} (see example below).


{pstd}
{cmd:adostorer} uses {cmd:adoupdate}, {cmd:net}, and {cmd:ssc} to do the main tasks.



{marker remarks}{...}
{title:Remarks}
{pstd}
An alternative strategy would be to download the installation files to a separate directory structure 
to create small package repository. Then each user could install the package (from the local repo)
to an unshared location (seprate from the project or in unversioned subfolders). This has the downside
of duplicating files and requires all users to manually install newly needed packages.

{marker examples}{...}
{title:Examples}
{pstd}
Let's assume that Stata is in the root of project folder and that the user
will install packages locatlly to 'code/ado'

{pstd}
Make sure packages are installed locally (once per session)

{phang}{cmd:. sysdir set PERSONAL "`c(pwd)'/code/ado"}{p_end}
{phang}{cmd:. net set ado PERSONAL}{p_end}
{phang}{cmd:. net set other PERSONAL}{p_end}

{pstd}
Make sure this machine can find it's platform-specific package files (once per session)

{phang}{cmd:. platformname}{p_end}
{phang}{cmd:. global S_ADO `"${S_ADO};code/ado/`r(platformname)'"'}{p_end}

{pstd}
Install the package from an online source.

{phang}{cmd:. adostorer {it:packagename}, adofolder(/code/ado) all mkdirs}{p_end}

{pstd}
Installing packages from a source relative to your current folder can be problematic.
For the stata.trk file to be machine-agnostic it should store the relative path.
But for updates to work stata.trk needs the absolute path of the package source.
The solutions is to normally keep relative paths in the stata.trk but temporarily change
them to relative when updates are needed.  If the package has platform-specific files, use {help adostorer}.

{phang}{cmd:. net install {it:package}, from({it:package_src_absolute_path})}{p_end}
{phang}{cmd:. make_trk_paths relative, adofolder({it:adofolder})}{p_end}

{pstd}
Update packages installed from a local source (could alternatively uninstall, and then reinstall as above).
If the package has platform-specific files, use {help adostorer}. 

{phang}{cmd:. make_trk_paths absolute, adofolder({it:adofolder})}{p_end}
{phang}{cmd:. adoupdate {it:package}, update}{p_end}
{phang}{cmd:. make_trk_paths relative, adofolder({it:adofolder})}{p_end}

