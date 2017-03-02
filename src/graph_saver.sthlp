{smcl}
{* *! version 0.1.0  28feb2017}{...}
{viewerjumpto "Syntax" "graph_saver##syntax"}{...}
{viewerjumpto "Description" "graph_saver##description"}{...}
{viewerjumpto "Options" "graph_saver##options"}{...}
{viewerjumpto "Reproducibility" "graph_saver##reproducibility"}{...}
{viewerjumpto "Remarks" "graph_saver##remarks"}{...}
{viewerjumpto "Examples" "graph_saver##examples"}{...}
{title:Title}

{phang}
{bf:graph_saver} {hline 2} Saves graph files in a reproducible manner.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:graph_saver}
[{it:graphname}]
{it:{help filename}}
[{cmd:,} {cmd:{opt v:ersion}(}{it:int}{cmd:)} {it:graph_save_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt v:ersion}{cmd:(}{it:int}{cmd:)}}If you want to save in earlier version.{p_end}
{synopt:{it:graph_save_options}}Any options to pass on to {cmd:graph save}. See {help graph save##options:graph save options}.{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:graph_saver} saves gph files that are "reproducible". 
Reproducible outputs will be exactly identical (byte-for-byte) if produced again with the same code and inputs.
Most Stata outputs are not exactly reproducible so that it is not enough to tell if a file's bytes changed to know if the content changed.
It can be difficult to tell if contents changed when non-reproducible outputs, since there are no built-in tools to see if gph files are different.
Reproducible outputs make both automated and manual check of files contents easier.
For a more complete treatment of benefits, see {help stata_reproducible}.


{pstd}
{cmd:graph_saver} is a front-end (replacement) for {cmd:{help graph save}}. 
{cmd:graph_saver} will call {cmd:graph save} and then edit the gph file to make it reproducible.
Currently, only graph file formats made natively by Stata version 11-14 are supported.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt version} allows specifying the version to save as. 
This can be helpful if you are using Stata v14 and would like to save the file in the format of Stata v13.
This allows the use of both Stata v13 and v14 to be used and to create identical output files.
A default can be provided by setting {it:$DEFAULT_OUT_VERSION} to "13" or "14" which allows both versions to be used on the same code without unnecessary code clutter.


{marker reproducibility}{...}
{title:Reproducibility}

{pstd}
The main sources of non-reproducibility in gph files are junk padding in the serset section, timestamps in the text portions, randomness in the element identifiers.


{pstd}
In addition, ths package aims to make similar files across platforms and versions. parallellilng -save, version()-, this extends the graphing command to older versions of stata (this did not exist before either via -graph save- or -version NN: graph save-). gph files are a mixture of binary and text portions and text portions are standardized to unix line endings.This package also standardizes line endings to unix

{marker remarks}{...}
{title:Remarks}
{pstd}
Can not be used on asis graphs.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. graph_saver {it:filename}, replace}{p_end}

{phang}{cmd:. graph_saver {it:filename}, version(13)}{p_end}

