{smcl}
{* *! version 0.1.0  28feb2017}{...}
{title:Title}

{phang}
{bf:platformname} {hline 2} Returns the platform code of the current machine.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:platformname}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:platformname} returns in {cmd:r(platformname)} the code of the platform of the current machine (e.g. {it:WIN64A}, {it:MACINTEL64}, {it:OSX.X8664}, or {it:LINUX64}).
These are used to identify different platforms for the installation of packages. See {help usersite} for "g lines".

{marker remarks}{...}
{title:Remarks}
{phang}
Some less common machines type, I either do not have access to nor enough information to determine them automatically: 
{it:MAC} (32-bit PowerPC), {it:OSX.PPC} (32-bit PowerPC), 
{it:SOL64}, and {it:SOLX8664} (64-bit x86-64)

{marker examples}{...}
{title:Examples}

{phang}{cmd:. platformname}{p_end}

