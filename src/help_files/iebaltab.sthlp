{smcl}
{* 5 Nov 2019}{...}
{hline}
help for {hi:iebaltab}
{hline}

{title:Title}

{phang2}{cmdab:iebaltab} {hline 2} produces balance tables with multiple groups or treatment arms

{phang2}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/Iebaltab":DIME Wiki}.

{title:Syntax}

{phang2}
{cmd:iebaltab} {it:balancevarlist} [{help if:if}] [{help in:in}] [{help weight}]
, {opt grpv:ar(varname)} [
{it:{help iebaltab##columnrowoptions:columnrow_options}}
{it:{help iebaltab##estimateoptions:estimation_options}}
{it:{help iebaltab##statoptions:stat_display_options}}
{it:{help iebaltab##labeloptions:label_options}}
{it:{help iebaltab##exportoptions:export_options}}
{it:{help iebaltab##latexoptions:latex_options}}
]

{phang2}where {it:balancevarlist} is one or several continuous or binary variables (from here on called balance variables) for which the command
will test for differences across the categories in grpvar({it:varname}). See note on non-binary categorical balance variables in the description section below.

{marker opts}{...}
{synoptset 22}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Required options:}}}{p_end}

{synopt :{opth grpv:ar(varname)}}Variable indicating groups (for example treatment arms){p_end}

{pstd}{it:    {ul:{hi:Optional options}}}{p_end}

{marker columnrowoptions}{...}
{synopthdr:Column and row options}
{synopt :{opt co:ntrol(groupcode)}}Indicate a single group that all other groups are tested against. Default is all groups are tested against each other{p_end}
{synopt :{opt or:der(groupcodelist)}}Manually set the order the groups appear in the table. Default is ascending. See details on {it:groupcodelist} below{p_end}
{synopt :{opt tot:al}}Include descriptive stats on all observations included in the table{p_end}
{synopt :{opt onerow}}Write number of observations (and number of clusters if applicable) in one row at the bottom of the table{p_end}

{marker estimateoptions}{...}
{synopthdr:Estimation options}
{synopt :{opth vce:(vce_option:vce_types)}}Options for estimating variance{p_end}
{synopt :{opth fix:edeffect(varname)}}Include fixed effects in the regressions for t-tests (and for F-tests if applicable){p_end}
{synopt :{opth cov:ariates(varlist)}}Include covariates (control variables) in the regressions for t-tests (and for F-tests if applicable){p_end}
{synopt :{opt ft:est}}Include a row with the F-test for joint significance across all balance variables for each test pair{p_end}
{synopt :{opt feqt:est}}Include a column with the F-test for joint significance across all groups for each variable{p_end}

{marker statoptions}{...}
{synopthdr:Stat display options}
{synopt :{cmd:stats(}{it:{help iebaltab##statstr:stats_string}}{cmd:)}}Specify which statistics to display in the tables. See options for {it:stats_string} below{p_end}
{synopt :{opth star:levels(numlist)}}Manually set the three significance levels used for significance stars{p_end}
{synopt :{opt starsno:add}}Do not add any stars to the table{p_end}
{synopt :{opth form:at(format:%fmt)}}Apply Stata formats to the values outputted in the table{p_end}

{marker labeloptions}{...}
{synopthdr:Label/notes options}
{synopt :{opt grpc:odes}}Use the values in the {opt grpvar()} variable as column titles even if the variable has value labels{p_end}
{synopt :{opt grpl:abels(codetitles)}}Manually set the group column titles. See details on {it:codetitles} below{p_end}
{synopt :{opt totall:abel(string)}}Manually set the title of the total column{p_end}
{synopt :{opt rowv:arlabels}}Use the variable labels instead of variable name as row titles{p_end}
{synopt :{opt rowl:abels(nametitles)}}Manually set the row titles. See details on {it:nametitles} below{p_end}
{synopt :{opt tbln:ote(string)}}Replace the default note at the bottom of the table{p_end}
{synopt :{opt tbladdn:ote(string)}}Add note to the default note at the bottom of the table{p_end}
{synopt :{opt tblnon:ote}}Suppresses any note at the bottom of the table{p_end}

{marker exportoptions}{...}
{synopthdr:Export options}
{synopt :{opt browse}}View table in the data browser{p_end}
{synopt :{opth savex:lsx(filename)}}Save table to Excel file on disk{p_end}
{synopt :{opth savec:sv(filename)}}Save table to csv-file on disk{p_end}
{synopt :{opth savet:ex(filename)}}Save table to LaTeX file on disk{p_end}
{synopt :{opth texnotefile(filename)}}Save table note in a separate LaTeX file on disk{p_end}
{synopt :{opt replace}}Replace file on disk if the file already exists{p_end}

{marker latexoptions}{...}
{synopthdr:LaTeX options}
{synopt :{opth texn:otewidth(numlist)}}Manually adjust width of note{p_end}
{synopt :{opt texc:aption(string)}}Specify LaTeX table caption{p_end}
{synopt :{opt texl:abel(string)}}Specify LaTeX label{p_end}
{synopt :{opt texdoc:ument}}Create a stand-alone LaTeX document{p_end}
{synopt :{opt texvspace(string)}}Manually set size of the line space between two rows on LaTeX output{p_end}
{synopt :{opt texcolwidth(string)}}Limit width of the first column on LaTeX output{p_end}

{synoptline}

{title:Description}

{pstd}{cmd:iebaltab} is a command that generates balance tables (difference-in-means tables).
The command tests for statistically significant difference in the balance variables between
the categories defined in the {opt grpvar(varname)}. The command can either test one control group
against all other groups, using the {opt control(groupcode)} option,
or test all groups against each other (the default). The command also allows for
fixed effects, covariates and different types of variance estimators.{p_end}

{pstd}The balance variables are expected to be continuous or binary variables.
Categorical variables (for example 1=single, 2=married, 3=divorced) will not
generate an error but will be treated like a continuous variable
which is most likely statistically invalid.
Consider converting each category to binary variables.{p_end}

{pstd}The command also attaches notes to the bottom of the table that
documents how the command was specified when the table was generated.
This automatic note is meant to be used during explorative analysis only and eventually
be replaced with a manual note suitable for publication using {opt tblnote(string)}.{p_end}

{title:Options (detailed descriptions)}

{pstd}{it:{ul:{hi:Required options:}}}{p_end}

{phang}{opth grpv:ar(varname)} specifies the variable indicating groups
(for example treatment arms) across which the command will
test for difference in mean of the balance variable.
The group variable can only be one variable and
it must be numeric and may only hold integers.
See {help egen:egen group} for help on creating a single variable where
each integer represents a category from string variables and/or multiple variables.
Observations with missing values in this variable will be excluded when running this command.

{pstd}{it:{ul:{hi:Optional options}}}{p_end}

{pstd}{it:Column and row options:}{p_end}

{phang}{opt co:ntrol(groupcode)} specifies one group that is the control group
that all other groups are tested against for difference in means and
where {it:groupcode} is an integer used in {opt grpvar()}.
The default is that all groups are tested against each other.
The control group will be listed first (leftmost) in the table
unless another order is specified in {opt order()}.
When using {opt control()} the order of the groups in the pair is (non-control)-(control)
so that a positive statistic (for example {it:diff} or {it:beta}) indicates that
the mean for the non-control is larger than for the control.{p_end}

{phang}{opt or:der(groupcodelist)} manually sets the column order of the groups in the table. {it:groupcodelist} may
be any or all of the values in the group variable specified in {opt grpvar()}.
The default order if this option is omitted is ascending order of the values in the group variable.
If any values in {opt grpvar()} are omitted when using this option,
they will be sorted in ascending order after the values included.{p_end}

{phang}{opt tot:al} includes a column with descriptive statistics on the full sample.
This column still exclude observations with missing values in {opt grpvar()}.{p_end}

{phang}{opt onerow} displays the number of observations in an additional row
at the bottom of the table. If the number of observations are not identical
across all rows within a column, then this option throws an error.
This also applies to number of clusters.
If not specified, the number of observations (and clusters) per variable per group
is displayed on the same row in an additional column
next to the descriptive statistics.{p_end}

{pstd}{it:Estimation options:}{p_end}

{phang}{opth vce:(vce_option:vce_types)} sets the type of variance estimator
to be used in all regressions for this command.
See {help vce_option:vce_types} for more details.
However, the types allowed in this command are only
{hi:robust}, {hi:cluster} {it:clustervar} or {hi:bootstrap}.
See the {help iebaltab##est_defs:estimation definition} section
for exact definitions on how these vce types are included in the regressions.{p_end}

{phang}{opth fix:edeffect(varname)} specifies a single variable to be used as fixed effects in all regressions
part from descriptive stats regressions.
The variable specified must be a numeric variable.
If more than one variable is needed as fixed effects, and it is not desirable to combine multiple variables into one
(using for example {help egen:egen group}),
then they can be included using the {opt i.} notation in the {opt covariates()} option.
See the {help iebaltab##est_defs:estimation definition} section for exact definitions on how the fixed effects are included in the regressions.{p_end}

{phang}{opth cov:ariates(varlist)} includes the variables specified in the regressions for t-tests (and for
F-tests if applicable) as covariate variables (control variables). See the description section above for details on how the covariates
are included in the estimation regressions. The covariate variables must be numeric variables.
See the {help iebaltab##est_defs:estimation definition} section for exact definitions on how the covariates are included in the regressions.{p_end}

{phang}{opt ft:est} add a single row at the bottom fo the the table with
one F-test for each test pair, testing for joint significance across all balance variables.
See the {help iebaltab##est_defs:estimation definition} section for exact definitions on how these tests are estimated.{p_end}

{phang}{opt feqt:est} adds a single column in the table with an F-test for each balance variable,
testing for joint significance across all groups in {opt grpvar()}.
See the {help iebaltab##est_defs:estimation definition} section for exact definitions on how these tests are estimated.{p_end}

{pstd}{it:Statistics display options:}{p_end}

{marker statstr}{...}
{phang}{cmd:stats(}{it:{help iebaltab##statstr:stats_string}}{cmd:)}
indicates which statistics to be displayed in the table.
The {it:stats_string} is expected to be on this format (where at least one of the sub-arguements
{opt desc}, {opt pair}, {opt f} and {opt feq} are required):{p_end}

{pmore}{cmd: stats(desc({it:desc_stats}) pair({it:pair_stats}) f({it:f_stats}) feq({it:feq_stats))}}{p_end}

{pmore}The table below lists the valid values for
{it:desc_stats}, {it:pair_stats}, {it:f_stats} and {it:feq_stats}.
See the {help iebaltab##est_defs:estimation definition} section
for exact definitions of these values and how they are estimated/calculated.{p_end}

{p2colset 9 21 23 0}{...}
{p2col:{it:desc_stats:}}{cmd:se var sd}{p_end}
{p2col:{it:pair_stats:}}{cmd:diff beta t p nrmd nrmb se sd none}{p_end}
{p2col:{it:f_stats:}}{cmd:f p}{p_end}
{p2col:{it:feq_stats:}}{cmd:f p}{p_end}

{phang}{opth star:levels(numlist)} manually sets the
three significance levels used for significance stars.
Expected input is decimals (between the value 0 and 1) in descending order.
The default is (.1 .05 .01) where .1 corresponds
to one star, .05 to two stars and .01 to three stars.{p_end}

{phang}{opt starsno:add} makes the command not add any stars to the table. This option makes the most sense in combination
with {cmd:pttest}, {cmd:pftest} or {cmd:pboth} but is possible to use by itself as well.{p_end}

{phang}{opth form:at(format:%fmt)} applies the Stata formats specified to all values outputted
in the table apart from values that always are integers.
Example of values that always are integers is number of observations.
For these integer values the format is always %9.0f.
The default for all other values when this option is not used is %9.3f.{p_end}

{pstd}{it:Label and notes options:}{p_end}

{phang}{opt grpc:odes} makes the integer values used for the group codes in
{opt grpvar()} the group column titles.
The default is to use the value labels used in {opt grpvar()}.
If no value labels are used for the variable in {opt grpvar()},
then this option does not make a difference.{p_end}

{phang}{opt grpl:abels(codetitles)} manually sets the group column titles.
{it:codetitles} is a string on the following format:{p_end}

{pmore}{opt grplabels("code1 title1 @ code2 title2 @ code3 title3")}{p_end}

{pmore}Where code1, code2 etc. must correspond to the integer values used for each
group used in the variable {opt grpvar()},
and title1, title2 etc. are the titles to be used for the corresponding integer value.
The character "@" may not be used in any title.
Codes omitted from this option will be assigned a column title
as if this option was not used.
This option takes precedence over {cmd:grpcodes} when used together,
meaning that group codes are only used for groups
that are not included in the {it:codetitlestring}.
The title can consist of several words.
Everything that follows the code until the end of a string
or a "@" will be included in the title.{p_end}

{phang}{opt totall:abel(string)} manually sets the column title for the total column.{p_end}

{phang}{opt rowv:arlabels} use the variable labels instead of variable name as row titles.
The default is to use the variable name. For variables with no variable label defined,
the variable name is used as row label even when this option is specified.{p_end}

{phang}{opt rowl:abels(nametitles)} manually sets the row titles for each
of the balance variables in the table.
{it:nametitles} is a string in the following format:{p_end}

{pmore}{opt rowlabels("name1 title1 @ name2 title2 @ name3 title3")}{p_end}

{pmore}Where name1, name2 etc. are variable names used as balance variables,
and title1, title2 etc. are the titles to be used for the corresponding variable.
The character "@" may not be used in any of the titles.
Variables omitted from this option are assigned a row title as if this option was not used.
This option takes precedence over {cmd:rowvarlabels} when used together,
meaning that default labels are only used for variables
that are not included in the {it:nametitlestring}.
The title can consist of several words.
Everything that follows the variable name until
the end of a string or a "@" will be included in the title.{p_end}

{phang}{opt tbln:ote(string)} replaces the default note at the bottom
of the table with this manually entered string.
The default note is a very informative string that will help you
remember exactly how you specified the command when generating the table.
But the default note is most likely not suitable
for the final publication of the table.
If exporting to LaTeX, the exact specification of the table is
written in a comment at the top of the LaTeX file.{p_end}

{phang}{opt tbladdn:ote(string)} adds the manually entered string to the default note at the bottom of the table.{p_end}

{phang}{opt tblnon:ote} makes this command not add any automatically generated or manually specified notes to the table.{p_end}

{pstd}{it:Export options:}{p_end}

{phang}{opt  browse} replaces the data in memory with the table
so it can be viewed using the command {h browse} instead of saving it to disk.
This is only meant to be used during explorative analysis
when figuring out how to specify the command.
Note that this overwrites data in memory.{p_end}

{phang}{opth savex:lsx(filename)} exports the table to an Excel (.xsl/.xlsx) file and saves it on disk.{p_end}

{phang}{opth savec:sv(filename)} exports the table to a comma separated (.csv) file and saves it on disk.{p_end}

{phang}{opth savet:ex(filename)} exports the table to a LaTeX (.tex) file and saves it on disk.{p_end}

{phang}{opth texnotefile(filename)} exports the table note in a separate LaTeX file on disk.
When this option is used, no note is included in the {opt savetex()} file.
This allows importing the table using the {it:threeparttable} LaTeX package which
is an easy way to make sure the note always has the same width as the table.
See example in the example section below.{p_end}

{phang}{opt replace} allows for the file in {opt savexlsx()}, {opt savexcsv()} or {opt savetex()}
to be overwritten if the file already exist on disk.{p_end}

{pstd}{it:LaTeX options:}{p_end}

{phang}{opth texn:otewidth(numlist)} manually adjusts the width of the note
to fit the size of the table.
The note width is a multiple of text width.
If not specified, default is one, which makes the table width equal to text width.
However, when the table is resized when rendered in LaTeX
this is not always the same as the table width.
Consider also using {opt texnotefile()} and the LaTeX package {it:threeparttable}.{p_end}

{phang}{opt texdoc:ument} creates a stand-alone LaTeX document ready to be compiled.
The default is that {opt savetex()} creates a fragmented LaTeX file
consisting only of a tabular environment.
This fragment is then meant to be imported to a main LaTeX file
that holds text and may import other tables.{p_end}

{phang}{opt texc:aption(string)} writes the table's caption in LaTeX file.
Can only be used with option {opt texdocument}.{p_end}

{phang}{opt texl:abel(string)} specifies table's label,
used for meta-reference across LaTeX file.
Can only be used with option {opt texdocument}.{p_end}

{phang}{opt texvspace(string)} sets the size of the line space between table rows.
{it:string} must consist of a numeric value with one of the following units:
"cm", "mm", "pt", "in", "ex" or "em".
Note that the resulting line space displayed will be equal to the
specified value minus the height of one line of text.
Default is "3ex". For more information on these units,
{browse "https://en.wikibooks.org/wiki/LaTeX/Lengths":check LaTeX lengths manual}.{p_end}

{phang}{cmd:texcolwidth(}{it:string}{cmd:)} limits the width of table's first column
so that a line break is added when a variable's name or label is too long.
{it:string} must consist of a numeric value with one of the following units:
"cm", "mm", "pt", "in", "ex" or "em".
For more information on these units,
{browse "https://en.wikibooks.org/wiki/LaTeX/Lengths":check LaTeX lengths manual}.{p_end}

{marker est_defs}{...}
{title:Estimation definitions and display options}

{pstd}This section details the regressions that are used to estimate
the statistics displayed in the in the generated balance tables.
For each test there is a {it:basic form} example to highlight the core of the test,
and an {it:all options} example that shows exactly how all options are applied.
Here is a glossary for the terms used in this section:{p_end}

{p2colset 5 23 23 0}{...}
{p2col:{it:balance variable}}The variables listed as {it:balancevarlist}{p_end}
{p2col:{it:groupvar}}The variable specified in {opt grpvar(varname)}{p_end}
{p2col:{it:groupcode}}Each value in {it:groupvar}{p_end}
{p2col:{it:test pair}}Combination of {it:group codes} to be used in pair wise tests{p_end}
{p2col:{it:tp_dummy}}A dummy variable where the first {it:group code} in a {it:test pair}
has the value 1 and the second {it:group code} has the value 0,
and all other observations has missing values{p_end}

{pstd}{ul:{it:Group descriptive statistics}}{break}
Descriptive statistics for all groups are always displayed in the table.
If option {opt total} is used then these statistics are also calculated on the full sample.
For each balance variable and for each value group code,
the descriptive statistics is calculated using the following code:{p_end}

{pstd}{it:basic form:}
{break}{input:reg balancevar if groupvar = groupcode}{p_end}

{pstd}{it:all options:}
{break}{input:reg balancevar if groupvar = groupcode weights, vce(vce_option)}{p_end}

{pstd}The table below shows the stats estimated/calculated based on this regression.
A star (*) in the {it:Stat} column indicate that is the optional statistics displayed by default
if the {inp:stats()} option is used.
The {it:Display option} column shows what sub-option to use in {inp:stats()} to display this statistic.
The {it:Mat col} column shows what the column name in the result matrix for the column that stores this stat.
{it:gc} stands for {it:groupcode}, see definition above.
See more about the result matrices in the {it:Result matrices} section below.
The last column shows how the command obtains the stat in the Stata code.{p_end}

{c TLC}{hline 9}{c TT}{hline 19}{c TT}{hline 9}{c TT}{hline 33}{c TRC}
{c |} Stat {col 11}{c |} Display option {col 31}{c |} Mat col {col 37}{c |} Estimation/calculation {col 75}{c |}
{c LT}{hline 9}{c +}{hline 19}{c +}{hline 9}{c +}{hline 33}{c RT}
{c |} # obs {col 11}{c |} Always displayed {col 31}{c |} n_{it:gc} {col 41}{c |} {cmd:e(N)} after {cmd:reg} {col 75}{c |}
{c |} cluster {col 11}{c |} Displayed if used {col 31}{c |} cl_{it:gc} {col 41}{c |} {cmd:e(N_clust)} after {cmd:reg} {col 75}{c |}
{c |} mean {col 11}{c |} Always displayed {col 31}{c |} mean_{it:gc} {col 41}{c |} {cmd:_b[cons]} after {cmd:reg} {col 75}{c |}
{c |} se * {col 11}{c |} {inp:stats(desc(se))} {col 31}{c |} se_{it:gc} {col 41}{c |} {cmd:_se[cons]} after {cmd:reg} {col 75}{c |}
{c |} var {col 11}{c |} {inp:stats(desc(var))} {col 31}{c |} var_{it:gc} {col 41}{c |} {cmd:e(rss)/e(df_r)} after {cmd:reg} {col 75}{c |}
{c |} sd {col 11}{c |} {inp:stats(desc(sd))} {col 31}{c |} sd_{it:gc} {col 41}{c |} {cmd:_se[_cons]*sqrt(e(N))} after {cmd:reg} {col 71}{c |}
{c BLC}{hline 9}{c BT}{hline 19}{c BT}{hline 9}{c BT}{hline 33}{c BRC}


{pstd}{ul:{it:Pair-wise test statistics}}{break}
Pair-wise test statistics is always displayed in the table
unless {cmd:stats(pair({it:none}))} is used.
For each balance variable and for each test pair, this code is used.
Since observations not included in the test pair have missing values in the test pair dummy,
they are excluded from the regression without using an if-statement.

{pstd}{it:basic form:}
{break}{input:reg balancevar tp_dummy}
{break}{input:test tp_dummy}{p_end}

{pstd}{it:all options:}
{break}{input:reg balancevar tp_dummy covariates i.fixedeffect weights, vce(vce_option)}
{break}{input:test tp_dummy}{p_end}

{pstd}The table below shows the stats estimated/calculated based on this regression.
A star (*) in the {it:Stat} column indicate that is the optional statistics displayed by default
if the {inp:stats()} option is used.
The {it:Display option} column shows what sub-option to use in {inp:stats()} to display this statistic.
The {it:Mat col} column shows what the column name in the result matrix for the column that stores this stat.
{it:tp} stands for {it:test pair}, see definition above.
See more about the result matrices in the {it:Result matrices} section below.
The last column shows how the command obtains the stat in the Stata code.
See the group descriptive statistics above for {inp:mean_1}, {inp:mean_2}, {inp:var_1} and {inp:var_2}
in the table below.{p_end}

{c TLC}{hline 8}{c TT}{hline 19}{c TT}{hline 9}{c TT}{hline 45}{c TRC}
{c |} Stat {col 10}{c |} Display option {col 30}{c |} Mat col {col 37}{c |} Estimation/calculation {col 86}{c |}
{c LT}{hline 8}{c +}{hline 19}{c +}{hline 9}{c +}{hline 45}{c RT}
{c |} diff * {col 8}{c |} {inp:stats(pair(diff))} {col 27}{c |} diff_{it:tp} {col 37}{c |} If pair 1_2: {inp:mean_1}-{inp:mean_2} {col 86}{c |}
{c |} beta {col 10}{c |} {inp:stats(pair(beta))} {col 27}{c |} beta_{it:tp} {col 37}{c |} {inp:e(b)[1,1]} after {inp:reg}{col 86}{c |}
{c |} t {col 10}{c |} {inp:stats(pair(t))} {col 30}{c |} t_{it:tp} {col 40}{c |} {inp:_b[tp_dummy]/_se[tp_dummy]} after {inp:reg}{col 86}{c |}
{c |} p {col 10}{c |} {inp:stats(pair(p))} {col 30}{c |} p_{it:tp} {col 40}{c |} {cmd:e(p)} after {cmd:test}{col 86}{c |}
{c |} nrmd {col 10}{c |} {inp:stats(pair(nrmd))} {col 30}{c |} nrmd_{it:tp} {col 40}{c |} If pair 1_2: {inp:diff_{it:tp}/sqrt(.5*(var_1+var_2))} {col 86}{c |}
{c |} nrmb {col 10}{c |} {inp:stats(pair(nrmb))} {col 30}{c |} nrmb_{it:tp} {col 40}{c |} If pair 1_2: {inp:beta_{it:tp}/sqrt(.5*(var_1+var_2))}{col 86}{c |}
{c |} se {col 10}{c |} {inp:stats(pair(se))} {col 30}{c |} se_{it:tp} {col 40}{c |} {cmd:_se[tp_dummy]} after {cmd:reg}{col 86}{c |}
{c |} sd {col 10}{c |} {inp:stats(pair(sd))} {col 30}{c |} sd_{it:tp} {col 40}{c |} {cmd:_se[tp_dummy] * sqrt(e(N))} after {cmd:reg}{col 86}{c |}
{c BLC}{hline 8}{c BT}{hline 19}{c BT}{hline 9}{c BT}{hline 45}{c BRC}


{pstd}{ul:{it:F-test statistics for balance across all balance variables}}{break}
Displayed if option {opt ftest} is used.
For each test pair the following code is used.

{pstd}{it:basic form:}
{break}{input:reg tp_dummy balancevars }
{break}{input:testparm balancevars}{p_end}

{pstd}{it:all options:}
{break}{input:reg tp_dummy balancevars covariates i.fixedeffect weights, vce(vce_option)}
{break}{input:testparm balancevars}{p_end}

{pstd}The table below shows the stats estimated/calculated based on this regression.
A star (*) in the {it:Stat} column indicate that is the optional statistics displayed by default
if the {inp:stats()} option is used.
The {it:Display option} column shows what sub-option to use in {inp:stats()} to display this statistic.
The {it:Mat col} column shows what the column name in the result matrix for the column that stores this stat.
{it:tp} stands for {it:test pair}, see definition above.
The f-test statistics is stored in a separate result matrix called {inp:r(iebaltabfmat)}
See more about the result matrices in the {it:Result matrices} section below.
The last column shows how the command obtains the stat in the Stata code.{p_end}

{c TLC}{hline 9}{c TT}{hline 19}{c TT}{hline 9}{c TT}{hline 24}{c TRC}
{c |} Stat {col 11}{c |} Display option {col 31}{c |} Mat col {col 41}{c |} Estimation/calculation {col 66}{c |}
{c LT}{hline 9}{c +}{hline 19}{c +}{hline 9}{c +}{hline 24}{c RT}
{c |} # obs {col 11}{c |} Always displayed {col 31}{c |} fn_{it:tp} {col 41}{c |} {cmd:e(N)} after {cmd:reg} {col 66}{c |}
{c |} cluster {col 11}{c |} Displayed if used {col 31}{c |} fcl_{it:tp} {col 41}{c |} {cmd:e(N_clust)} after {cmd:reg} {col 66}{c |}
{c |} f * {col 11}{c |} {inp:stats(f(f))} {col 31}{c |} ff_{it:tp} {col 41}{c |} {cmd:r(F)} after {cmd:testparm} {col 66}{c |}
{c |} p {col 11}{c |} {inp:stats(f(p))} {col 31}{c |} fp_{it:tp} {col 41}{c |} {cmd:r(p)} after {cmd:testparm} {col 66}{c |}
{c BLC}{hline 9}{c BT}{hline 19}{c BT}{hline 9}{c BT}{hline 24}{c BRC}

{pstd}{ul:{it:F-test statistics for balance across all groups}}{break}
Dipslayed in the table if the option {opt feqtest} is used.
For each balance variable this code is used.
{it:feqtestinput} is a list on the format
{input:x2.groupvar=x3.groupvar...xn.groupvar=0}, where {input:x2}, {input:x3} ... {input:xn},
represents all group codes apart from the first code.

{pstd}{it:basic form:}
{break}{input:reg balancevar i.groupvar}
{break}{input:test feqtestinput}{p_end}

{pstd}{it:all options:}
{break}{input:reg balancevar i.groupvar covariates i.fixedeffect weights, vce(vce_option)}
{break}{input:test feqtestinput}{p_end}

{pstd}The table below shows the stats estimated/calculated based on this regression.
A star (*) in the {it:Stat} column indicate that is the optional statistics displayed by default
if the {inp:stats()} option is used.
The {it:Display option} column shows what sub-option to use in {inp:stats()} to display this statistic.
The {it:Mat col} column shows what the column name in the result matrix for the column that stores this stat.
See more about the result matrices in the {it:Result matrices} section below.
The last column shows how the command obtains the stat in the Stata code.{p_end}

{c TLC}{hline 9}{c TT}{hline 19}{c TT}{hline 9}{c TT}{hline 24}{c TRC}
{c |} Stat {col 11}{c |} Display option {col 31}{c |} Mat col {col 41}{c |} Estimation/calculation {col 66}{c |}
{c LT}{hline 9}{c +}{hline 19}{c +}{hline 9}{c +}{hline 24}{c RT}
{c |} # obs {col 11}{c |} Always displayed {col 31}{c |} feqn {col 41}{c |} {cmd:e(N)} after {cmd:reg} {col 66}{c |}
{c |} cluster {col 11}{c |} Displayed if used {col 31}{c |} feqcl {col 41}{c |} {cmd:e(N_clust)} after {cmd:reg} {col 66}{c |}
{c |} f * {col 11}{c |} {inp:stats(feq(f))} {col 31}{c |} feqf {col 41}{c |} {cmd:r(F)} after {cmd:test} {col 66}{c |}
{c |} p {col 11}{c |} {inp:stats(feq(p))} {col 31}{c |} feqp {col 41}{c |} {cmd:r(p)} after {cmd:test} {col 66}{c |}
{c BLC}{hline 9}{c BT}{hline 19}{c BT}{hline 9}{c BT}{hline 24}{c BRC}



{title:Examples}

{pstd} {hi:Example 1.}

{pmore}{inp:sysuse census}{break}
{inp:gen group = runiform() < .5}{break}
{inp:iebaltab pop medage, grpvar(group) browse}{break}
{inp:browse}{p_end}

{pmore}In the example above, Stata's built in census data is used.
First a dummy variable is created at random.
Using this random group variable a balance table is created testing for
differences in {inp:pop} and {inp:medage}.
By using {inp:browse} the data in memory is replaced with the table so that
the table can be used in the browse window.
You most likely never should use the {inp:browse} option in your final code
but it is convenient in examples like this and when first testing the command.
See examples on how to save file to disk below.{p_end}

{pstd} {hi:Example 2.}

{pmore}{inp:sysuse census}{break}
{inp:iebaltab pop medage, grpvar(region) browse}{break}
{inp:browse}{p_end}

{pmore}In this example we use the variable region as group variable that has four categories.
All groups are tested against each other.{p_end}

{pstd} {hi:Example 3.}

{pmore}{inp:sysuse census}{break}
{inp:iebaltab pop medage, grpvar(region) browse control(4)}{break}
{inp:browse}{p_end}

{pmore}Comparing all groups against each other becomes unfeasible when the number of
categories in the group variable grows.
The option {inp:control()} overrides this behavior so that the category indicated
in this options are tested against all other groups,
but the other groups are not tested against each other.
For statistics where the direction matters (for example {it:diff} or {it:beta})
the order is changed so that the test is ({it:other_group} - {it:control})
such that a positive value indicates that the other group has a higher
mean in the balance variable.{p_end}

{pstd} {hi:Example 4.}

{pmore}{inp:sysuse census}{break}
{inp:iebaltab pop medage, grpvar(region) browse control(4) stats(desc(var) pair(p))}{break}
{inp:browse}{p_end}

{pmore}You can control which statistics to output in using the {inp:stats()} option.
In this example, the sub-option {inp:desc(var)} indicates that
the variance should be displayed in the descriptive statistics section
instead of standard error which is the default.
The sub-option {inp:pair(p)} indicates that
the p-value in from the t-tests in the pairwise test section should be displayed
instead of the difference in mean between the groups which is the default.
See above in this help file for full details on the sub-options you may use.{p_end}

{pstd} {hi:Example 5.}

{pmore}{inp:sysuse census}{break}
{inp:local outfld {it:"path/to/folder"}}{break}
{inp:iebaltab pop medage, grpvar(region) control(4) ///}{break}
{space 2}{inp:stats(desc(var) pair(p)) replace ///}{break}
{space 2}{inp:savecsv("`outfld'/iebtb.csv") savexlsx("`outfld'/iebtb.xlsx") ///}{break}
{space 2}{inp:savetex("`outfld'/iebtb.tex") texnotefile("`outfld'/iebtb_note.tex")}{p_end}

{pmore}This example shows how to export the tables to the three formats supported.
CSV, Excel and LaTeX.
To run this code you must update the path {it:"path/to/folder"} to point
to a folder on your computer where the tables can be exported to.
This is what we recommend over using the {inp:browse} options for final code.
When exporting to LaTeX we recommend exporting the note to a seperate file
using the option {inp:texnotefile()} and then import it in LaTeX using the
package {inp:threeparttable} like the code below.
It makes it easier to align the note with the table when LaTeX adjust the size
of the table to fit a page.

	{input}
	\begin{table}
	  \centering
	  \caption{Balance table}
	  \begin{adjustbox}{max width=\textwidth}
	    \begin{threeparttable}[!h]
		  \input{./balancetable.tex}
		  \begin{tablenotes}[flushleft]
		    \item\hspace{-.25em}\input{./balancetable_note.tex}
		  \end{tablenotes}
	    \end{threeparttable}
	  \end{adjustbox}
	\end{table}
	{text}

{title:Author}

{phang}All commands in ietoolkit are developed by DIME Analytics at DIME, The World Bank's department for Development Impact Evaluations.

{phang}Main authors: Kristoffer Bjarkefur, Luiza Cardoso De Andrade, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "ietoolkit iebaltab" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/ietoolkit":the GitHub repository of ietoolkit}.{p_end}
