{smcl}
{* *! version 0.1.0  28feb2017}{...}
{viewerjumpto "Syntax" "saver##syntax"}{...}
{viewerjumpto "Description" "saver##description"}{...}
{viewerjumpto "Options" "saver##options"}{...}
{viewerjumpto "Reproducibility" "saver##reproducibility"}{...}
{viewerjumpto "Remarks" "saver##remarks"}{...}
{viewerjumpto "Examples" "saver##examples"}{...}
{title:Title}

{phang}
{bf:saver} {hline 2} Saves datasets in a reproducible manner.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:saver:}
[{it:{help filename}}]
[{cmd:,} {cmd:{opt v:ersion}} {it:save_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt v:ersion}}If you want to save in earlier version.{p_end}
{synopt:{it:save_options}}Any options to pass on to {cmd:save}. See {help save##save_options:save options}.{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:saver} saves dta files that are "reproducible". 
Reproducible outputs will be exactly identical (byte-for-byte) if produced again with the same code and inputs.
Most Stata outputs are not exactly reproducible so that it is not enough to tell if a file's bytes changed to know if the content changed.
It can be difficult to tell if contents changed when non-reproducible outputs, since the built-in tools of {help cf} and {help datasignature} don't compare labels, notes, or {help characteristics}).
Reproducible outputs make both automated and manual check of files contents easier.
For a more complete treatment of benefits, see {help stata_reproducible}.


{pstd}
{cmd:saver} is a front-end (replacement) for {cmd:{help save}}. 
{cmd:saver} will call {cmd:save} and then edit the data file in-place to make it reproducible.
Currently, only dta file formats made natively by Stata version 13 and 14 are supported.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt version} allows specifying the version to save as. 
This can be helpful if you are using Stata v14 and would like to save the file in the format of Stata v13.
This allows the use of both Stata v13 and v14 to be used and to create identical output files (assuming they use the same {help help f_byteorder:byteorder}).
A default can be provided by setting {it:$DEFAULT_OUT_VERSION} to "13" or "14".


{marker reproducibility}{...}
{title:Reproducibility}

{pstd}
The main sources of non-reproducibility in dta files are timestamps and junk padding.
Timestamps are present in the header of the data file and possibly in characeteristics ({cmd:saver} knows about the one set by {cmd:datasignature}).
Padding is unused area in the file. These vary when saving the file at different time. 
This often happens when a field is fixed width but only a portion is needed.
For example, if a string field is {it:L} bytes wide then shorter strings will have be "terminated" by appending a null byte (\0). 
Any remaining space in the field is unused and can vary.
{cmd:saver} zeros out all the padding so that they are the same between runs.

{marker remarks}{...}
{title:Remarks}
{pstd}
By default, timestamps are normalized to "01 Jan 2001 01:01". 
The user can override this by setting the global {it:$DEFAULT_OUT_DT} using the same format or the environment variable {it:SOURCE_DATE_EPOCH} to the unix timestamp (seconds since 01-01-1970). 
If both are set the global takes priority.

{pstd}
If the post-processing in {cmd:saver} is slow, try to exclude fixed-width string variables( or separate into another dataset) as this requires processing per-observation.

{pstd}
This command aims to normalize all elements (e.g. characteristics) added by common base commands, of which the only one currently is _dta[datasignature_dt] (used by datasignature).
User-commands may add other non-reproducible elements and the burden to normalize these falls on the user.

{pstd}
The use of {it:preserve} and {it:restore} swaps the order of characteristics and the order of value labels. {cmd:saver} does not normalize these orderings.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. saver {it:filename}, replace}{p_end}

{phang}{cmd:. saver {it:filename}, version(13)}{p_end}

