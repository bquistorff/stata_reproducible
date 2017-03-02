{smcl}
{* *! version 0.1.0  28feb2017}{...}
{viewerjumpto "Syntax" "log_closer##syntax"}{...}
{viewerjumpto "Description" "log_closer##description"}{...}
{viewerjumpto "Options" "log_closer##options"}{...}
{viewerjumpto "Reproducibility" "log_closer##reproducibility"}{...}
{viewerjumpto "Remarks" "log_closer##remarks"}{...}
{viewerjumpto "Examples" "log_closer##examples"}{...}
{title:Title}

{phang}
{bf:log_closer} {hline 2} Saves datasets in a reproducible manner.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:log_closer}
{it:logname}
[{cmd:,} {cmd:{opt delete_line_user}}{cmd:(}{it:string}{cmd:)} 
{cmd:{opt rw_line_user_pre}}{cmd:(}{it:string}{cmd:)}
{cmd:{opt rw_line_user_post}}{cmd:(}{it:string}{cmd:)}
{cmd:{opt raw_dir}}{cmd:(}{it:string}{cmd:)}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt delete_line_user}{cmd:(}{it:string}{cmd:)}} Name of a user's mata program that decided whether to delete a line.{p_end}
{synopt:{opt rw_line_user_pre}{cmd:(}{it:string}{cmd:)}} Name of a user's mata program that rewrites a line before built-in rewriting.{p_end}
{synopt:{opt rw_line_user_post}{cmd:(}{it:string}{cmd:)}} Name of a user's mata program that rewrites a line after built-in rewriting.{p_end}
{synopt:{opt raw_dir}{cmd:(}{it:string}{cmd:)} }A directory to store the original raw log file.{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:log_closer} saves log files that are "reproducible". 
Reproducible outputs will be exactly identical (byte-for-byte) if produced again with the same code and inputs.
Most Stata outputs are not exactly reproducible so that it is not enough to tell if a file's bytes changed to know if the content changed.
It can be difficult to tell if contents changed when non-reproducible outputs, since there are no built-in tools to see if gph files are different.
Reproducible outputs make both automated and manual check of files contents easier.
For a more complete treatment of benefits, see {help stata_reproducible}.

{pstd}
{cmd:log_closer} also tries to make log files completely normalized so that they are the same if they 
are produced on a different machine (OS, directory, Stata version). As user-written programs
may make machine-specific changes, this procedure is extensible with the user-written mata programs.


{pstd}
{cmd:log_closer} is a front-end (replacement) for {cmd:{help log} close}. 
{cmd:log_closer} will call {cmd:log close} and then edit the file to make it reproducible.
Currently, only log file formats made natively by Stata version 13 and 14 are supported.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt delete_line_user} The name of a mata program that takes two string arguments, 
(1) the line, and (2) the log type ("log" or "smcl").
It returns 1 if the line should be removed from the final log file or 0 if not.

{phang}
{opt rw_line_user_pre}/{opt rw_line_user_post} The name of mata programs that takes two string arguments, 
(1) the line, and (2) the log type ("log" or "smcl").
They return a re-written line that will be outpututed.
One is called before the built-in re-writing rules and the other after.

{phang}
{opt raw_dir} A directory to store the original raw log file.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. log_closer {it:logname}}{p_end}

