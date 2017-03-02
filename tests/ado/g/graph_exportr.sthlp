{smcl}
{* *! version 0.1.0  28feb2017}{...}
{viewerjumpto "Syntax" "graph_exportr##syntax"}{...}
{viewerjumpto "Description" "graph_exportr##description"}{...}
{viewerjumpto "Reproducibility" "graph_exportr##reproducibility"}{...}
{viewerjumpto "Remarks" "graph_exportr##remarks"}{...}
{viewerjumpto "Examples" "graph_exportr##examples"}{...}
{title:Title}

{phang}
{bf:graph_exportr} {hline 2} Saves graph export files in a reproducible manner.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:graph_exportr}
{it:{help filename}}
[{cmd:,} {it:graph_export_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{it:graph_export_options}}Any options to pass on to {cmd:graph export}. See {help graph export##options:graph export options}.{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:graph_exportr} saves graph export files that are "reproducible". 
Reproducible outputs will be exactly identical (byte-for-byte) if produced again with the same code and inputs.
Most Stata outputs are not exactly reproducible so that it is not enough to tell if a file's bytes changed to know if the content changed.
It can be difficult to tell if contents changed when non-reproducible outputs, since there are no built-in tools to see if gph files are different.
Reproducible outputs make both automated and manual check of files contents easier.
For a more complete treatment of benefits, see {help stata_reproducible}.


{pstd}
{cmd:graph_exportr} is a front-end (replacement) for {cmd:{help graph export}}. 
{cmd:graph_exportr} will call {cmd:graph export} and then edit the gph file to make it reproducible.
Currently, only graph file formats made natively by Stata version 13-14 are supported.


{marker reproducibility}{...}
{title:Reproducibility}

{pstd}
Some formats can not yet be made reproducible: emf,

{pstd}
The main sources of non-reproducibility in exported graph files are pdfs.
These sometimes (Windows on Stata v13) have timestamps and randomness.

{marker remarks}{...}
{title:Remarks}
{pstd}
By default, timestamps are normalized to "01 Jan 2001 01:01". 
The user can override this by setting the global {it:$DEFAULT_OUT_DT} using the same format or the environment variable {it:SOURCE_DATE_EPOCH} to the unix timestamp (seconds since 01-01-1970). 
If both are set the global takes priority.

{pstd}
Notes on implementatins: Stata v13 on Windows uses JagPDF 1.4.0 making PDF 1.5 docs. Stata v14 on Windows and Unix uses Haru Free PDF Library 2.4.0dev. On Unix it makes PDF-1.3 and on Windows PDF-1.6.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. graph_exportr {it:filename}, replace}{p_end}

