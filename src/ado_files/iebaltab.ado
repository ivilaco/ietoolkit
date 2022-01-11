*! version 6.3 5NOV2019 DIME Analytics dimeanalytics@worldbank.org

	capture program drop iebaltab,
	program define iebaltab, rclass

		syntax varlist(numeric) [if] [in] [aw fw pw iw],                    ///
                                                                        ///
				/*Group variable*/                                              ///
				GRPVar(varname)                                                 ///
				[                                                               ///
				/*Columns and order of columns*/                                ///
				ORder(numlist int min=1) COntrol(numlist int max=1) TOTal       ///
                                                                        ///
				/*Column and row labels*/                                       ///
				GRPCodes GRPLabels(string) TOTALLabel(string) ROWVarlabels      ///
				ROWLabels(string) onerow                                        ///
				                                                                ///
				/*Statistics and data manipulation*/                            ///
				FIXedeffect(varname) COVariates(varlist ts fv) COVARMISSOK      ///
				vce(string)   MISSMINmean(numlist min=1 max=1 >0)               ///
				WEIGHTold(string)                                               ///
				                                                                ///
				/*F-test and  FEQTest*/                                   ///
				FTest FMissok FEQTest	                                     ///
				                                                                ///
				/*Output display*/                                              ///
				pairoutput(string) foutput(string)  ///
				 STDev              ///
				STARlevels(numlist descending min=3 max=3 >0 <1)			          ///
				STARSNOadd FORMat(string) TBLNote(string)	NOTECombine	TBLNONote	///
				                                                                ///
				/*Export and restore*/                                          ///
				SAVEXlsx(string) SAVECsv(string) SAVETex(string) TEXNotewidth(numlist min=1 max=1)  ///
				TEXCaption(string) TEXLabel(string) TEXDOCument	texvspace(string) ///
				texcolwidth(string) REPLACE BROWSE                         ///
				                                                                ///
				/*Deprecated options
				  - still included to throw helpful error if ever used */       ///
				 SAVEBRowse BALMISS(string) BALMISSReg(string)            ///
				COVMISS(string) COVMISSReg(string) SAVE(string)                 ///
				]



		********HELPFILE TODO*********
		*1. Explain difference in se between group by itself and the standard errors used in the t-test

	preserve
qui {

	/***********************************************
	************************************************

		Version, weight and if/in sample

	*************************************************
	************************************************/

	*Set minimum version for this command
	version 12

	* Backwards compatibility for weight option
		if "`weightold'" != "" & "`exp'" == "" {
			tokenize `weightold', parse(=)
			local weight "`1'"
			local exp = "= `3'"
		}

		*Remove observations excluded by if and in
		marksample touse,  novarlist
		keep if `touse'

	/***********************************************
	************************************************

		Set initial constants

	*************************************************
	************************************************/

		*Create local for balance vars with more descriptive name
		local balancevars `varlist'

		tempname rmat fmat


	** Column Options

		*Is option control() used:
		if "`control'" 			== "" local CONTROL_USED = 0
		if "`control'" 			!= "" local CONTROL_USED = 1

		*Is option order() used:
		if "`order'" 			== "" local ORDER_USED = 0
		if "`order'" 			!= "" local ORDER_USED = 1

		*Is option grpcodes used:
		if "`grpcodes'"			== "" local NOGRPLABEL_USED = 0
		if "`grpcodes'" 		!= "" local NOGRPLABEL_USED = 1

		*Is option nolabel used:
		if "`grplabels'" 		== "" local GRPLABEL_USED = 0
		if "`grplabels'" 		!= "" local GRPLABEL_USED = 1

		*Is option total() used:
		if "`total'" 			== "" local TOTAL_USED = 0
		if "`total'" 			!= "" local TOTAL_USED = 1

		*Is option totallable() used:
		if "`totallabel'" 		== "" local TOTALLABEL_USED = 0
		if "`totallabel'" 		!= "" local TOTALLABEL_USED = 1


	** Row Options

		*Is option total() used:
		if "`rowvarlabels'" 	== "" local ROWVARLABEL_USED = 0
		if "`rowvarlabels'" 	!= "" local ROWVARLABEL_USED = 1

		*Is option totallable() used:
		if "`rowlabels'" 		== "" local ROWLABEL_USED = 0
		if "`rowlabels'" 		!= "" local ROWLABEL_USED = 1

		*Is option totallable() used:
		if "`onenrow'" 			!= "" local onerow = "onerow" //Old name still supported for backward compatibility
		if "`onerow'" 			== "" local ONEROW_USED = 0
		if "`onerow'" 			!= "" local ONEROW_USED = 1


	** Stats Options

		*Is option ftest used:
		if "`ftest'" 			== "" local FTEST_USED = 0
		if "`ftest'" 			!= "" local FTEST_USED = 1

		*Is option fmiss used:
		if "`fmissok'" 			== "" local F_MISS_OK = 0
		if "`fmissok'" 			!= "" local F_MISS_OK = 1

		*Is option fnoobs used:
		if "`fnoobs'" 			== "" local F_NO_OBS = 0
		if "`fnoobs'" 			!= "" local F_NO_OBS = 1

		*Is option fixedeffect() used:
		if "`fixedeffect'"		== "" local FIX_EFFECT_USED = 0
		if "`fixedeffect'" 		!= "" local FIX_EFFECT_USED = 1

		*Is option covariates() used:
		if "`covariates'"		== "" local COVARIATES_USED = 0
		if "`covariates'" 		!= "" local COVARIATES_USED = 1

		*Is option covarmissok used:
		if "`covarmissok'"		== "" local COVARMISSOK_USED = 0
		if "`covarmissok'" 		!= "" local COVARMISSOK_USED = 1

		*Is option cluster() used:
		if "`vce'" 				== "" local VCE_USED = 0
		if "`vce'" 				!= "" local VCE_USED = 1

		*Is option balmiss() used:
		if "`balmiss'" 			== "" local BALMISS_USED = 0
		if "`balmiss'" 			!= "" local BALMISS_USED = 1

		*Is option missreg() used:
		if "`balmissreg'" 		== "" local BALMISSREG_USED = 0
		if "`balmissreg'" 		!= "" local BALMISSREG_USED = 1

		*Is option covmiss() used:
		if "`covmiss'" 			== "" local COVMISS_USED = 0
		if "`covmiss'" 			!= "" local COVMISS_USED = 1

		*Is option covmissreg() used:
		if "`covmissreg'" 		== "" local COVMISSREG_USED = 0
		if "`covmissreg'" 		!= "" local COVMISSREG_USED = 1

		*Is option missminmean() used:
		if "`missminmean'" 		== "" local MISSMINMEAN_USED = 0
		if "`missminmean'" 		!= "" local MISSMINMEAN_USED = 1

		*Is option starlevels() used:
		if "`starlevels'" 		== "" local STARLEVEL_USED = 0
		if "`starlevels'" 		!= "" local STARLEVEL_USED = 1

		*Is option starsnoadd used:
		if "`starsnoadd'" 		== "" local STARSNOADD_USED = 0
		if "`starsnoadd'" 		!= "" local STARSNOADD_USED = 1

		*Is option nottest used:
		if "`nottest'"			== "" local TTEST_USED = 1
		if "`nottest'"			!= "" local TTEST_USED = 0

		*Is option pttest() used:
		if "`pttest'" 			== "" local PTTEST_USED = 0
		if "`pttest'" 			!= "" local PTTEST_USED = 1

		*Is option pftest() used:
		if "`pftest'" 			== "" local PFTEST_USED = 0
		if "`pftest'" 			!= "" local PFTEST_USED = 1

		*Is option pboth() used:
		if "`pboth'" 			== "" local PBOTH_USED 	= 0
		if "`pboth'" 			!= "" local PBOTH_USED 	= 1
		if `PBOTH_USED' == 1 		  local PTTEST_USED = 1
		if `PBOTH_USED' == 1 		  local PFTEST_USED = 1

		*Is option pftest() used:
		if "`stdev'" 			== "" local STDEV_USED = 0
		if "`stdev'" 			!= "" local STDEV_USED = 1

		*Is option weight() used:
		if "`weight'" 			== "" local WEIGHT_USED = 0
		if "`weight'" 			!= "" local WEIGHT_USED = 1

		*Is option feqtest() user:
		if "`feqtest'" 			== "" local FEQTEST_USED = 0
		if "`feqtest'" 			!= "" local FEQTEST_USED = 1

		*Is option normdiff() used:
		if "`normdiff'" 		== "" local NORMDIFF_USED = 0
		if "`normdiff'" 		!= "" local NORMDIFF_USED = 1


	** Output Options

		*Is option format() used:
		if "`format'" 			== "" local FORMAT_USED = 0
		if "`format'" 			!= "" local FORMAT_USED = 1

		*Is option savexlsx() used:
		if "`savexlsx'" 		== "" local SAVE_XSLX_USED = 0
		if "`savexlsx'" 		!= "" local SAVE_XSLX_USED = 1

		*Is option savecsv() used:
		if "`savecsv'" 			== "" local SAVE_CSV_USED = 0
		if "`savecsv'" 			!= "" local SAVE_CSV_USED = 1

		*Is option savetex() used:
		if "`savetex'" 			== "" local SAVE_TEX_USED = 0
		if "`savetex'" 			!= "" local SAVE_TEX_USED = 1

		local SAVE_USED = max(`SAVE_CSV_USED',`SAVE_TEX_USED')

		*Is option texnotewidth() used:
		if "`texnotewidth'"		== "" local NOTEWIDTH_USED = 0
		if "`texnotewidth'"		!= "" local NOTEWIDTH_USED = 1

		*Is option texnotewidth() used:
		if "`texcaption'"		== "" local CAPTION_USED = 0
		if "`texcaption'"		!= "" local CAPTION_USED = 1

		*Is option texnotewidth() used:
		if "`texlabel'"			== "" local LABEL_USED = 0
		if "`texlabel'"			!= "" local LABEL_USED = 1

		*Is option texdocument() used:
		if "`texdocument'"		== "" local TEXDOC_USED = 0
		if "`texdocument'"		!= "" local TEXDOC_USED = 1

		*Is option texlinespace() used:
		if "`texvspace'"		== "" local TEXVSPACE_USED = 0
		if "`texvspace'"		!= "" local TEXVSPACE_USED = 1

		*Is option texcolwidth() used:
		if "`texcolwidth'"		== "" local TEXCOLWIDTH_USED = 0
		if "`texcolwidth'"		!= "" local TEXCOLWIDTH_USED = 1

		*Is option browse() used:
		if "`browse'" 			== "" local BROWSE_USED = 0
		if "`browse'" 			!= "" local BROWSE_USED = 1

		*Is option restore() used:
		if "`savebrowse'" 		== "" local SAVE_BROWSE_USED = 0
		if "`savebrowse'" 		!= "" local SAVE_BROWSE_USED = 1

		*Is option restore() used:
		if "`replace'" 			== "" local REPLACE_USED = 0
		if "`replace'" 			!= "" local REPLACE_USED = 1

		*Is option tablenote() used:
		if "`tblnote'" 			== "" local NOTE_USED = 0
		if "`tblnote'" 			!= "" local NOTE_USED = 1

		*Is option notecombine() used:
		if "`notecombine'" 		== "" local NOTECOMBINE_USED = 0
		if "`notecombine'" 		!= "" local NOTECOMBINE_USED = 1

		*Is option notablenote() used:
		if "`tblnonote'" 		== "" local NONOTE_USED = 0
		if "`tblnonote'" 		!= "" local NONOTE_USED = 1


	/***********************************************
	************************************************

		Prepare a list of group variables

	*************************************************
	************************************************/

		cap confirm numeric variable `grpvar'

		if _rc != 0 {

			*Test for commands not allowed if grpvar is a string variable

			if `CONTROL_USED' == 1 {
				di as error "{pstd}The option control() can only be used if variable {it:`grpvar'} is a numeric variable. Use {help encode} to generate a numeric version of variable {it:`grpvar'}. It is best practice to store all categorical variables as labeled numeric variables.{p_end}"
				error 198
			}
			if `ORDER_USED' == 1 {
				di as error "{pstd}The option order() can only be used if variable {it:`grpvar'} is a numeric variable. Use {help encode} to generate a numeric version of variable {it:`grpvar'}. It is best practice to store all categorical variables as labeled numeric variables.{p_end}"
				error 198
			}
			if `NOGRPLABEL_USED' == 1 {
				di as error "{pstd}The option grpcodes can only be used if variable {it:`grpvar'} is a numeric variable. Use {help encode} to generate a numeric version of variable {it:`grpvar'}. It is best practice to store all categorical variables as labeled numeric variables.{p_end}"
				error 198
			}
			if `GRPLABEL_USED' == 1 {
				di as error "{pstd}The option grplabels() can only be used if variable {it:`grpvar'} is a numeric variable. Use {help encode} to generate a numeric version of variable {it:`grpvar'}. It is best practice to store all categorical variables as labeled numeric variables.{p_end}"
				error 198
			}

			*Generate a encoded tempvar version of grpvar
			tempvar grpvar_code
			encode `grpvar' , gen(`grpvar_code')

			*replace the grpvar local so that it uses the tempvar instead
			local grpvar `grpvar_code'

		}

		** TODO allow string var

		*Remove observations with a missing value in grpvar()
		drop if missing(`grpvar')

		*Create a local of all codes in group variable
		levelsof `grpvar', local(GRP_CODES)

		*Saving the name of the value label of the grpvar()
		local GRPVAR_VALUE_LABEL 	: value label `grpvar'

		*Counting how many levels there are in groupvar
		local GRPVAR_NUM_GROUPS : word count `GRP_CODES'

		*Static dummy for grpvar() has no label
		if "`GRPVAR_VALUE_LABEL'" == "" local GRPVAR_HAS_VALUE_LABEL = 0
		if "`GRPVAR_VALUE_LABEL'" != "" local GRPVAR_HAS_VALUE_LABEL = 1

		*Number of columns for Latex
		local NUM_COL_GRP_TOT = `GRPVAR_NUM_GROUPS' + `TOTAL_USED'


/*******************************************************************************
*******************************************************************************/

		*Testing all options and generate locals from the input to be used
		*across the command

/*******************************************************************************
*******************************************************************************/

	** Group Options

		cap confirm numeric variable `grpvar'
		if _rc != 0 {
			noi display as error "{phang}The variable listed in grpvar(`grpvar') is not a numeric variable. See {help encode} for options on how to make a categorical string variable into a categorical numeric variable{p_end}"
			error 108
		}
		else {
			** Testing that groupvar is a categorical variable. Int() rounds to
			* integer, and if any values are non-integers then (int(`grpvar') == `grpvar) is
			* not true
			cap assert ( int(`grpvar') == `grpvar' )
			if _rc == 9 {
				noi display as error  "{phang}The variable in grpvar(`grpvar') is not a categorical variable. The variable may only include integers where each integer indicates which group each observation belongs to. See tabulation of `grpvar' below:{p_end}"
				noi tab `grpvar', nol
				error 109
			}
		}


	** Column Options

		** If control() or order() is used, then the levels specified in those
		*  options need to exist in the groupvar

		local control_correct : list control in GRP_CODES
		if `control_correct' == 0 {
			noi display as error "{phang}The code listed in control(`control') is not used in grpvar(`grpvar'). See tabulation of `grpvar' below:"
			noi tab `grpvar', nol
			error 197
		}

		local order_correct : list order in GRP_CODES
		if `order_correct' == 0 {
			noi display as error  "{phang}One or more codes listed in order(`order') are not used in grpvar(`grpvar'). See tabulation of `grpvar' below:"
			noi tab `grpvar', nol
			error 197
		}

		if `GRPLABEL_USED' == 1 {

			local col_labels_to_tokenize `grplabels'

			while "`col_labels_to_tokenize'" != "" {

				*Parsing code and label pair
				gettoken codeAndLabel col_labels_to_tokenize : col_labels_to_tokenize, parse("@")

				*Splitting code and label
				gettoken code label : codeAndLabel


				*** Codes

				*Checking that code exist in grpvar and store it
				local code_correct : list code in GRP_CODES
				if `code_correct' == 0 {
					noi display as error  "{phang}Code [`code'] listed in grplabels(`grplabels') is not used in grpvar(`grpvar'). See tabulation of `grpvar' below:"
					noi tab `grpvar', nol
					error 198
				}

				*Storing the code in local to be used later
				local grpLabelCodes `"`grpLabelCodes' "`code'" "'


				*** Labels

				*Removing leadning or trailing spaces
				local label = trim("`label'")

				*Testing that no label is missing
				if "`label'" == "" {
					noi display as error "{phang}For code [`code'] listed in grplabels(`grplabels') you have not specified any label. Labels are requried for all codes listed in grplabels(). See tabulation of `grpvar' below:"
					noi tab `grpvar', nol
					error 198
				}

				*Storing the label in local to be used later
				local grpLabelLables `"`grpLabelLables' "`label'" "'


				*Parse char is not removed by gettoken
				local col_labels_to_tokenize = subinstr("`col_labels_to_tokenize'" ,"@","",1)
			}
		}

		if `ROWLABEL_USED' {

			*** Test the validity for the rowlabel input

			*Create a local with the rowlabel input to be tokenized
			local row_labels_to_tokenize `rowlabels'

			while "`row_labels_to_tokenize'" != "" {

				*Parsing name and label pair
				gettoken nameAndLabel row_labels_to_tokenize : row_labels_to_tokenize, parse("@")

				*Splitting name and label
				gettoken name label : nameAndLabel

				*** Variable names

				*Checking that the variables used in rowlabels() are included in the table
				local name_correct : list name in balancevars
				if `name_correct' == 0 {
					noi display as error "{phang}Variable [`name'] listed in rowlabels(`rowlabels') is not found among the variables included in the balance table."
					error 111
				}

				*Storing the code in local to be used later
				local rowLabelNames `"`rowLabelNames' "`name'" "'


				*** Variable labels

				*Removing leading or trailing spaces
				local label = trim("`label'")

				*Testing that no label is missing
				if "`label'" == "" {
					noi display as error "{phang}For variable [`name'] listed in rowlabels(`rowlabels') you have not specified any label. Labels are requried for all variables listed in rowlabels(). The variable name itself will be used for any variables omitted from rowlabels(). See also option {help iebaltab:rowvarlabels}"
					noi tab `grpvar', nol
					error 198
				}

				*Storing the label in local to be used later
				local rowLabelLabels `"`rowLabelLabels' "`label'" "'

				*Parse char is not removed by gettoken
				local row_labels_to_tokenize = subinstr("`row_labels_to_tokenize'" ,"@","",1)
			}
		}

		if `TOTALLABEL_USED' & !`TOTAL_USED' {

			*Error for totallabel() incorrectly applied
			noi display as error "{phang}Option totallabel() may only be used together with the option total"
			error 197
		}


	** Stats Options
		local CLUSTER_USED 0

		if `VCE_USED' == 1 {

			local vce_nocomma = subinstr("`vce'", "," , " ", 1)

			tokenize "`vce_nocomma'"
			local vce_type `1'

			if "`vce_type'" == "robust" {

				*Robust is allowed and not other tests needed
			}
			else if "`vce_type'" == "cluster" {

				*Create a local for displaying number of clusters
				local CLUSTER_USED 1

				local cluster_var `2'

				cap confirm variable `cluster_var'

				if _rc {

					*Error for vce(cluster) incorrectly applied
					noi display as error "{phang}The cluster variable in vce(`vce') does not exist or is invalid for any other reason. See {help vce_option :help vce_option} for more information. "
					error _rc

				}
			}
			else if  "`vce_type'" == "bootstrap" {

				*bootstrap is allowed and not other tests needed. Error checking is more comlex, add tests here in the future.
			}
			else {

				*Error for vce() incorrectly applied
				noi display as error "{phang}The vce type `vce_type' in vce(`vce') is not allowed. Only robust, cluster and bootstrap are allowed. See {help vce_option :help vce_option} for more information."
				error 198

			}
		}

		if `STARSNOADD_USED' == 0 {

			*Allow user defined p-values for stars or set the default values
			if `STARLEVEL_USED' == 1 {

				*Tokenize the string with the p-values entered by the user. The value entered are tested in syntax
				tokenize "`starlevels'"

				*Set user defined levels for 1, 2 and 3 stars
				local p1star `1'
				local p2star `2'
				local p3star `3'
			}
			else {
				*Set default levels for 1, 2 and 3 stars
				local p1star .1
				local p2star .05
				local p3star .01
			}

			** Create locals with the values expressed
			*  as percentages for the note to the table
			local p1star_percent = `p1star' * 100
			local p2star_percent = `p2star' * 100
			local p3star_percent = `p3star' * 100
		}
		else {

			*Options starsomitt is used. No stars will be displayed. By setting
			*these locals to nothing the loop adding stars will not be iterated
			local p1star
			local p2star
			local p3star
		}

		*Error for starlevels incorrectly used together with starsnoadd
		if `STARSNOADD_USED' & `STARLEVEL_USED' {
			*Error for starlevels and starsnoadd incorrectly used together
			noi display as error "{phang}Option starlevels() may not be used in combination with option starsnoadd"
			error 197
		}



		*Error for miss incorrectly used together with missreg
		if `BALMISS_USED' & `BALMISSREG_USED' {
			*Error for balmiss and balmissreg incorrectly used together
			noi display as error "{phang}Option balmiss() may not be used in combination with option balmissreg()"
			error 197
		}

		if `COVMISS_USED' & `COVMISSREG_USED' {
			*Error for covmiss and covmissreg incorrectly used together
			noi display as error "{phang}Option covmiss() may not be used in combination with option covmissreg()"
			error 197
		}

		if !`TTEST_USED' {
			if `PTTEST_USED' {
				*Error for nottest and pttest incorrectly used together
				noi display as error "{phang}Option pttest may not be used in combination with option nottest"
				error 197
			}
			if `PBOTH_USED' {
				*Error for nottest and pboth incorrectly used together
				noi display as error "{phang}Option pboth may not be used in combination with option nottest"
				error 197
			}
		}

		if `FTEST_USED' & !`TTEST_USED' & !`NORMDIFF_USED' {
			*Error for F-test used, but not t-test of normalized difference:
			*no columns are created for F-test to be displayed
			noi di as error "{phang}Option ftest may not only be used if either t-tests or normalized differences are used. F-test for joing significance of balance variables will not be displayed. In order to display it, either use option normdiff or remove option nottest.{p_end}"
			local FTEST_USED = 0

		}




		if `FIX_EFFECT_USED' == 1 {

			cap assert `fixedeffect' < .
			if _rc == 9 {

				noi display as error  "{phang}The variable in fixedeffect(`fixedeffect') is missing for some observations. This would cause observations to be dropped in the estimation regressions. See tabulation of `fixedeffect' below:{p_end}"
				noi tab `fixedeffect', m
				error 109
			}

		}

		* test covariate variables
		if `COVARIATES_USED' == 1  {

			foreach covar of local covariates {

				*Create option string
				local replaceoptions

				*Sopecify differently based on all missing or only regualr missing
				if `COVMISS_USED' 					local replaceoptions `" `replaceoptions' replacetype("`covmiss'") "'
				if `COVMISSREG_USED' 				local replaceoptions `" `replaceoptions' replacetype("`covmissreg'") regonly "'

				*Add group variable if the replace type is group mean
				if "`covmiss'" 		== "groupmean" 	local replaceoptions `" `replaceoptions' groupvar(`grpvar') groupcodes("`GRP_CODES'") "'
				if "`covmissreg'" 	== "groupmean" 	local replaceoptions `" `replaceoptions' groupvar(`grpvar') groupcodes("`GRP_CODES'") "'

				*Set the minimum number of observations to allow means to be set from
				if `MISSMINMEAN_USED' == 1			local replaceoptions `" `replaceoptions' minobsmean(`missminmean') "'
				if `MISSMINMEAN_USED' == 0			local replaceoptions `" `replaceoptions' minobsmean(10) "'

				*Excute the command. Code is found at the bottom of this ado file
				if (`COVMISS_USED' | `COVMISSREG_USED')  iereplacemiss `covariates', `replaceoptions'

				if `COVARMISSOK_USED' != 1 {

					cap assert `covar' < .
					if _rc == 9 {

						noi display as error  "{phang}The variable `covar' specified in covariates() has missing values for one or more observations. This would cause observations to be dropped in the estimation regressions. To allow for observations to be dropped see option covarmissok and to make the command treat missing values as zero see option covmiss() and covmissreg(). Click {stata tab `covar' `if' `in', m} to see the missing values.{p_end}"
						error 109
					}
				}
			}
		}

		if `WEIGHT_USED' == 1 {

			* Parsing weight options
			local weight_type = "`weight'"

			* Parsing keeps the separating character
			local weight_var = subinstr("`exp'","=","",.)

			* Test is weight type specified is valie
			local weight_options "fweights pweights aweights iweights fweight pweight aweight iweight fw freq weight pw aw iw"

			if `:list weight_type in weight_options' == 0 {

				noi display as error  "{phang} The option `weight_type' specified in weight() is not a valid weight option. Weight options are: fweights, fw, freq, weight, pweights, pw, aweights, aw, iweights, and iw. {p_end}"
				error 198

			}

			* Test is weight variable specified if valid
			capture confirm variable `weight_var'

			if _rc {

				noi display as error  "{phang} The option `weight_var' specified in weight() is not a variable. {p_end}"
				error 198
			}
		}



	** Output Options

		** If the format option is specified, then test if there is a valid format specified
		if `FORMAT_USED' == 1 {

			** Creating a numeric mock variable that we attempt to apply the format
			*  to. This allows us to piggy back on Stata's internal testing to be
			*  sure that the format specified is at least one of the valid numeric
			*  formats in Stata
				tempvar  formattest
				gen 	`formattest' = 1
			cap	format  `formattest' `format'

			if _rc == 120 {

				di as error "{phang}The format specified in format(`format') is not a valid Stata format. See {help format} for a list of valid Stata formats. This command only accept the f, fc, g, gc and e format.{p_end}"
				error 120
			}
			else if _rc != 0 {

				di as error "{phang}Something unexpected happened related to the option format(`format'). Make sure that the format you specified is a valid format. See {help format} for a list of valid Stata formats. If this problem remains, please report this error to kbjarkefur@worldbank.org.{p_end}"
				error _rc
			}
			else {
				** We know here that the format is one of the numeric formats that Stata allows

				local fomrmatAllowed 0
				local charLast  = substr("`format'", -1,.)
				local char2Last = substr("`format'", -2,.)

				if  "`charLast'" == "f" | "`charLast'" == "e" {
					local fomrmatAllowed 1
				}
				else if "`charLast'" == "g" {
					if "`char2Last'" == "tg" {
						*format tg not allowed. all other valid formats ending on g are allowed
						local fomrmatAllowed 0
					}
					else {

						*Formats that end in g that is not tg can only be g which is allowed.
						local fomrmatAllowed 1
					}
				}
				else if  "`charLast'" == "c" {
					if "`char2Last'" != "gc" & "`char2Last'" != "fc" {
						*format ends on c but is neither fc nor gc
						local fomrmatAllowed 0
					}
					else {

						*Formats that end in c that are either fc or gc are allowed.
						local fomrmatAllowed 1
					}
				}
				else {
					*format is neither f, fc, g, gc nor e
					local fomrmatAllowed 0
				}
				if `fomrmatAllowed' == 0 {
					di as error "{phang}The format specified in format(`format') is not allowed. Only format f, fc, g, gc and e are allowed. See {help format} for details on Stata formats.{p_end}"
					error 120
				}
				*If format passed all tests, store it in the local used for display formats
				local diformat = "`format'"
			}
		}
		else {
			*Default value if fomramt not specified
			local diformat = "%9.3f"
		}


		*Error for tblnonote incorrectly used together with notecombine
		if `NOTECOMBINE_USED' & `NONOTE_USED' {

			*Error for tblnonote incorrectly used together with notecombine
			noi display as error "{phang}Option tblnonote may not be used in combination with option notecombine"
			error 197
		}

		if `SAVE_USED' {
			if `SAVE_CSV_USED' {

				**Find the last . in the file path and assume that
				* the file extension is what follows. If a file path has a . then
				* the file extension must be explicitly specified by the user.

				*Copy the full file path to the file suffix local
				local file_suffix 	= "`save'"

				** Find index for where the file type suffix start
				local dot_index 	= strpos("`file_suffix'",".")

				*If no dot then no file extension
				if `dot_index' == 0  local file_suffix 	""

				**If there is one or many . in the file path than loop over
				* the file path until we have found the last one.
				while `dot_index' > 0 {

					*Extract the file index
					local file_suffix 	= substr("`file_suffix'", `dot_index' + 1, .)

					*Find index for where the file type suffix start
					local dot_index 	= strpos("`file_suffix'",".")
				}

				*If no file format suffix is specified, use the default .xlsx
				if "`file_suffix'" == "" {

					local save `"`save'.xlsx"'
				}

				*If a file format suffix is specified make sure that it is one of the two allowed.
				else if !("`file_suffix'" == "xls" | "`file_suffix'" == "xlsx") {

					noi display as error "{phang}The file format specified in save(`save') is other than .xls or .xlsx. Only those two formats are allowed. If no format is specified .xlsx is the default. If you have a . in your file path, for example in a folder name, then you must specify the file extension .xls or .xlsx.{p_end}"
					error 198
				}
			}
			if `SAVE_TEX_USED' {

				**Find the last . in the file path and assume that
				* the file extension is what follows. If a file path has a . then
				* the file extension must be explicitly specified by the user.

				*Copy the full file path to the file suffix local
				local tex_file_suffix 	= "`savetex'"

				** Find index for where the file type suffix start
				local tex_dot_index 	= strpos("`tex_file_suffix'",".")

				*If no dot then no file extension
				if `tex_dot_index' == 0  local tex_file_suffix 	""

				**If there is one or many . in the file path than loop over
				* the file path until we have found the last one.
				while `tex_dot_index' > 0 {

					*Extract the file index
					local tex_file_suffix 	= substr("`tex_file_suffix'", `tex_dot_index' + 1, .)

					*Find index for where the file type suffix start
					local tex_dot_index 	= strpos("`tex_file_suffix'",".")
				}

				*If no file format suffix is specified, use the default .tex
				if "`tex_file_suffix'" == "" {

					local savetex `"`savetex'.tex"'
				}

				*If a file format suffix is specified make sure that it is one of the two allowed.
				else if !("`tex_file_suffix'" == "tex" | "`tex_file_suffix'" == "txt") {

					noi display as error "{phang}The file format specified in savetex(`savetex') is other than .tex or .txt. Only those two formats are allowed. If no format is specified .tex is the default. If you have a . in your file path, for example in a folder name, then you must specify the file extension .tex or .txt.{p_end}"
					error 198
				}

				if `CAPTION_USED' {

					* Make sure special characters are displayed correctly
					local texcaption : subinstr local texcaption "%"  "\%" , all
					local texcaption : subinstr local texcaption "_"  "\_" , all
					local texcaption : subinstr local texcaption "&"  "\&" , all

				}
			}

		}
		else if `SAVE_BROWSE_USED' {

			noi display as error "{phang}Option savepreserve may only be used in combination with option save(){p_end}"
			error 198
		}

		* Check tex options
		if `SAVE_TEX_USED' {

			* Note width must be positive
			if `NOTEWIDTH_USED' {

				if `texnotewidth' <= 0 {

					noi display as error `"{phang}The value specified in texnotewidth(`texnotewidth') is non-positive. Only positive numbers are allowed. For more information, {net "from http://en.wikibooks.org/wiki/LaTeX/Lengths.smcl":check LaTeX lengths manual}.{p_end}"'
					error 198
				}
			}

			* Tex label must be a single word
			if `LABEL_USED' {

				local label_words : word count `texlabel'

				if `label_words' != 1 {

					noi display as error `"{phang}The value specified in texlabel(`texlabel') is not allowed. For more information, {browse "https://en.wikibooks.org/wiki/LaTeX/Labels_and_Cross-referencing":check LaTeX labels manual}.{p_end}"'
					error 198
				}

			}

			if (`LABEL_USED' | `CAPTION_USED') {

				if `TEXDOC_USED' == 0 {

					noi display as error "{phang}Options texlabel and texcaption may only be used in combination with option texdocument {p_end}"
					error 198
				}
			}

			if `TEXCOLWIDTH_USED' {

				* Test if width unit is correctly specified
				local 	texcolwidth_unit = substr("`texcolwidth'",-2,2)
				if 	!inlist("`texcolwidth_unit'","cm","mm","pt","in","ex","em") {
					noi display as error `"{phang}Option texcolwidth is incorrectly specified. Column width unit must be one of "cm", "mm", "pt", "in", "ex" or "em". For more information, {browse "https://en.wikibooks.org/wiki/LaTeX/Lengths":check LaTeX lengths manual}.{p_end}"'
					error 198
				}

				* Test if width value is correctly specified
				local 	texcolwidth_value = subinstr("`texcolwidth'","`texcolwidth_unit'","",.)
				capture confirm number `texcolwidth_value'
				if _rc & inlist("`texcolwidth_unit'","cm","mm","pt","in","ex","em") {
					noi display as error "{phang}Option texcolwidth is incorrectly specified. Column width value must be numeric. See {help iebaltab:iebaltab help}. {p_end}"
					error 198
				}
			}

			if `TEXVSPACE_USED' {

				* Test if width unit is correctly specified
				local 	vspace_unit = substr("`texvspace'",-2,2)
				if 	!inlist("`vspace_unit'","cm","mm","pt","in","ex","em") {
					noi display as error `"{phang}Option texvspace is incorrectly specified. Vertical space unit must be one of "cm", "mm", "pt", "in", "ex" or "em". For more information, {browse "https://en.wikibooks.org/wiki/LaTeX/Lengths":check LaTeX lengths manual}.{p_end}"'
					error 198
				}

				* Test if width value is correctly specified
				local 	vspace_value = subinstr("`texvspace'","`vspace_unit'","",.)
				capture confirm number `vspace_value'
				if _rc & inlist("`vspace_unit'","cm","mm","pt","in","ex","em") {
					noi display as error "{phang}Option texvspace is incorrectly specified. Vertical space value must be numeric. See {help iebaltab:iebaltab help}. {p_end}"
					error 198
				}
			}
		}

		* Error for incorrectly using tex options
		else if `NOTEWIDTH_USED' | `LABEL_USED' | `CAPTION_USED' | `TEXDOC_USED' | `TEXVSPACE_USED' | `TEXCOLWIDTH_USED' {

			noi display as error "{phang}Options texnotewidth, texdocument, texlabel, texcaption, texvspace and texcolwidth may only be used in combination with option savetex(){p_end}"
			error 198

		}


/*******************************************************************************
*******************************************************************************/

		* Set up the result matrix that will store all the results

/*******************************************************************************
*******************************************************************************/

	************************************************
	*Group order

		* If option order is always used to set the orders of the group columns. If
		* option control is used when order is not used, then the code for the
		* control group will be used in order.
		if !`ORDER_USED' & `CONTROL_USED' local order `control'

		* Put all group codes not in local order in local order_code_rest. If
		* neither option order or control were used, then local order_code_rest is
		* identical to local GRP_CODES
		local order_code_rest : list GRP_CODES - order

		* The final order is compiled by combining local order with local
		* order_code_rest. If neither option order or control were used, then local
		* ORDER_OF_GROUP_CODES is identical to local order_code_rest and GRP_CODES
		local ORDER_OF_GROUP_CODES `order' `order_code_rest'

		* Loop from the second element in the list of group codes to the last and
		* create a list on the format 2.tmt=3.tmt=0 where tmt is the grpvar and the
		* first value is dropped as the regression that test for joint orthogonality
		* for across all groups for each balance var will drop the lowest value in grpvar.
		local FEQTEST_INPUT ""
		forvalues grp_code_count = 2/`: word count `GRP_CODES'' {
			local this_code : word `grp_code_count' of `GRP_CODES'
			local FEQTEST_INPUT "`FEQTEST_INPUT'`this_code'.`grpvar'="
		}
		local FEQTEST_INPUT "`FEQTEST_INPUT'0"

		************************************************
		*Generate list of test pairs

		local TEST_PAIR_CODES = ""

		if `CONTROL_USED' {
			*Loop over all non-control codes and create pairs with them and the control code
			local non_control_codes : list ORDER_OF_GROUP_CODES - control
			foreach code_2 of local non_control_codes {
				local TEST_PAIR_CODES = "`TEST_PAIR_CODES' `control'_`code_2'"
			}
		}
		else {
			* Nested loop where values used in the outer loop is removed from the
			* inner loop to not make any duplicated pais such as 1_2 and 2_1.
			local ORDER_OF_GROUP_CODES_2 = "`ORDER_OF_GROUP_CODES'"
			foreach code_1 of local ORDER_OF_GROUP_CODES {
				local ORDER_OF_GROUP_CODES_2 : list ORDER_OF_GROUP_CODES_2 - code_1
				foreach code_2 of local ORDER_OF_GROUP_CODES_2 {
					local TEST_PAIR_CODES = "`TEST_PAIR_CODES' `code_1'_`code_2'"
				}
			}
		}

		*Number of test pairs
		local COUNT_TEST_PAIRS : list sizeof TEST_PAIR_CODES

		noi di "`ORDER_OF_GROUP_CODES'"

		************************************************
		* Setup tempvar dummies for each test pair that is
		* 0 for first code and 1 for second code and
		* missing for all other observations.
		foreach ttest_pair of local TEST_PAIR_CODES {

			*Get each code from a testpair
			getCodesFromPair `ttest_pair'
			local code1 `r(code1)'
			local code2 `r(code2)'

			*Tempvar dummy for the codes in the test pair and missing for other obs
			tempvar  dummy_pair_`ttest_pair'
			gen     `dummy_pair_`ttest_pair'' = .
			replace `dummy_pair_`ttest_pair'' = 0 if `grpvar' == `code1'
			replace `dummy_pair_`ttest_pair'' = 1 if `grpvar' == `code2'
		}

		do "C:\Users\wb462869\GitHub\ietoolkit\src\ado_files\iebaltab_setupmatrix.ado"

		* Set up the matrix for all stats and estimates
		noi setUpResultMatrix, order_of_group_codes(`ORDER_OF_GROUP_CODES') test_pair_codes(`TEST_PAIR_CODES')
		mat emptyRow  = r(emptyRow)
		mat `rmat' = r(emptyRow)
		mat `fmat'  = r(emptyFRow)

		local desc_stats   `r(desc_stats)'
	  local pair_stats   `r(pair_stats)'
		local allgrp_stats `r(allgrp_stats)'
		local ftest_stats  `r(ftest_stats)'

		noi mat list emptyRow
		noi mat list `fmat'

/*******************************************************************************
*******************************************************************************/

		* Set up locals with all column and row labels

/*******************************************************************************
*******************************************************************************/

	************************************************
	* Prepare column lables for groups


		*Local that will store the final labels. These labels will be stored in the in final order of groups in groupvar
		local COLUMN_LABELS ""

		*Loop over all groups in the final order
		foreach groupCode of local ORDER_OF_GROUP_CODES {

			************
			* Manually defined column label

			*Test if this code was listed in option GRPLabels()
			local grpLabelPos : list posof "`groupCode'" in grpLabelCodes

			*If index is not zero then manual label is defined, use it
			if `grpLabelPos' != 0 {
				*Getting the manually defined label and add it to local GROUP_LABELS
				local 	group_label : word `grpLabelPos' of `grpLabelLables'
				local	COLUMN_LABELS `" `COLUMN_LABELS' "`group_label'" "'
			}

			************
			* Use code as column label

			* If option grpcodes was used or grpvar has no value label, then the codes
			* must be used as column labels
			else if `NOGRPLABEL_USED' | !`GRPVAR_HAS_VALUE_LABEL' {
				*Not using value labels, simply using the group code as the label in the final table
				local	COLUMN_LABELS `" `COLUMN_LABELS' "`groupCode'" "'
			}

			************
			* Use value label in grpvar as column label

			* Grpvar has value labels and grpcodes was not used, then use value labels
			* as code labels
			else {
				*Get the value label corresponding to this code and use as label
				local gprVar_valueLabel : label `GRPVAR_VALUE_LABEL' `groupCode'
				local COLUMN_LABELS `" `COLUMN_LABELS' "`gprVar_valueLabel'" "'
			}
		}

		************************************************
		* Prepare row lables for each balance var

		local ROW_LABELS ""

		foreach balancevar of local balancevars {

			************
			* Manually defined row label

			** Test if this variable has a manually defined rowlabel in rowlabels()
			local rowLabPos : list posof "`balancevar'" in rowLabelNames
			*If index is not zero then manual label is defined, use it
			if `rowLabPos' != 0 {
				*Get the manually defined label for this balance variable
				local 	row_label : word `rowLabPos' of `rowLabelLabels'
				local ROW_LABELS `" `rowLabels_final' "`row_label'" "'
			}

			************
			* Use var label in balance var as row label

			*Use variable label if option is specified
			else if `ROWVARLABEL_USED' {
				*Get the variable label used for this variable and trim it
				local var_label : variable label `balancevar'
				local var_label = trim("`var_label'")
				* If varaible label exists, use it, oterwise use the variable name
				if "`var_label'" != "" local ROW_LABELS `" `ROW_LABELS' "`var_label'" "'
				else local ROW_LABELS `" `ROW_LABELS' "`balancevar'" "'
			}

			************
			* Use variable name as row label

			* If no manually row labels are defined, and option rowvarlabels is
			* not used, then use balance var name
			else local ROW_LABELS `" `ROW_LABELS' "`balancevar'" "'
		}

		************************************************
		* Prepare column label for total column

		* Use custom total label or default : "Total"
		if `TOTALLABEL_USED' local tot_lbl `totallabel'
		else local tot_lbl "Total"

/*******************************************************************************
*******************************************************************************/

		* Generate all stats and estimates

/*******************************************************************************
*******************************************************************************/

	*****************************************************************************
	*** Setting default values or specified values for fixed effects and clusters

		**********************************
		*Preparing fixed effect option
		if !`FIX_EFFECT_USED' {
			* If a fixed effect var is not specified, so that areg may be uses. A
			* fixed effect with no variation does not have any effect on the estimates
			tempvar  fixedeffect
			gen 	`fixedeffect' = 1
		}

		**********************************
		*Preparing cluster option

		* The varname for cluster is prepared to be put in the areg options. If
		* option vce() was not used then this local will be left empty
		if `VCE_USED' local error_estm vce(`vce')

		**********************************
		*Preparing weight option

		* The varname for weight is prepared to be put in the reg options. If no
		* weight was used then this option will be left empty
		if `WEIGHT_USED' local weight_option "[`weight_type' = `weight_var']"


	** Create locals that control the warning table

			*Mean test warnings
			local warn_means_num    	0
			local warn_ftest_num    	0

			*Joint test warnings
			local warn_joint_novar_num	0
			local warn_joint_lovar_num	0
			local warn_joint_robus_num	0


	*****************************************************************************
	*** Loop over each balance var and create the stats

		foreach balancevar in `balancevars' {

			* Make a copy of the empty row template to populate this row with
			mat row = emptyRow
			mat rownames row = `balancevar'

			*Local that keeps track of which column to fill
			local colindex 0

			******************************************************
			*** Get descriptive stats for each group

			foreach group_code of local ORDER_OF_GROUP_CODES {

				noi di "Desc stats. Var [`balancevar'], group code [`group_code']"
				reg 	`balancevar' if `grpvar' == `group_code' `weight_option', `error_estm'

				*Number of observation for this balancevar for this group
				mat row[1,`++colindex'] = e(N)
				*If clusters used, number of clusters in this balance var for this group, otherwise .c
				local ++colindex
				if "`vce_type'" == "cluster" mat row[1,`colindex'] = e(N_clust)
				else mat row[1,`colindex'] = .c
				*Mean of balance var for this group
				mat row[1,`++colindex'] = _b[_cons]
				*Standard error of balance var for this group
				mat row[1,`++colindex'] = _se[_cons]
				*Standard deviation of balance var for this group
				local sd = _se[_cons] * sqrt(e(N))
				mat row[1,`++colindex'] = `sd'

			}

			******************************************************
			*** Get descriptive stats for total

			noi di "Desc stats. Var [`balancevar'], total"
			if !missing("`total'") {
				* Estimate descriptive stats for total
				reg 	`balancevar'  `weight_option', `error_estm'
				*Number of observation for this balancevar for this group
				mat row[1,`++colindex'] = e(N)
				*If clusters used, number of clusters in this balance var for this group, otherwise .c
				local ++colindex
				if "`vce_type'" == "cluster" mat row[1,`colindex'] = e(N_clust)
				else mat row[1,`colindex'] = .c
				*Mean of balance var for this group
				mat row[1,`++colindex'] = _b[_cons]
				*Standard error of balance var for this group
				mat row[1,`++colindex'] = _se[_cons]
				*Standard deviation of balance var for this group
				local sd = _se[_cons] * sqrt(e(N))
				mat row[1,`++colindex'] = `sd'
			}
			else {
				*If total not specified, then put .m in all total columns
				foreach tot_stat of local desc_stats {
					mat row[1,`++colindex'] = .m
				}
			}

			******************************************************
			*** Get test estimates for each test pair

			foreach ttest_pair of local TEST_PAIR_CODES {

				*Get each code from a testpair
        getCodesFromPair `ttest_pair'
				local code1 `r(code1)'
				local code2 `r(code2)'

				local colnum_mean_code1 = colnumb(row,"mean_`code1'")
				local colnum_mean_code2 = colnumb(row,"mean_`code2'")
				mat row[1,`++colindex'] = el(row,1,`colnum_mean_code1') - el(row,1,`colnum_mean_code2')

				* The command mean is used to test that there is variation in the
				* balance var across these two groups. The regression that includes
				* fixed effects and covariaties might run without error even if there is
				* no variance across the two groups. The local varloc will determine if
				* an error or a warning will be thrown or if the test results will be
				* replaced with an "N/A".
				if "`error_estm'" != "vce(robust)" 	local mean_error_estm `error_estm' //Robust not allowed in mean, but the mean here
				noi di "Test var. Var [`balancevar'], test pair [`ttest_pair']"
				mean `balancevar', over(`dummy_pair_`ttest_pair'') 	 `mean_error_estm'
				mat var = e(V)
				local varloc = max(var[1,1],var[2,2])

				*Calculate standard deviation for sample of interest
				sum `balancevar' if !missing(`dummy_pair_`ttest_pair'')
				tempname scal_sd
				scalar `scal_sd' = r(sd)

				*Testing result and if valid, write to file with or without stars
				if `varloc' == 0 {

					local warn_means_num  	= `warn_means_num' + 1

					local warn_means_name`warn_means_num'	"t-test"
					local warn_means_group`warn_means_num' 	"(`code1')-(`code2')"
					local warn_means_bvar`warn_means_num'	"`balancevar'"

					* Adding missing value for each stat that is missing due to not running regression
					foreach stat in baln balcl beta t p {
						mat row[1,`++colindex'] = .v
					}
				}

				else {

					* Perform the balance test for this test pair for this balance var
					noi di "Balance regression. Var [`balancevar'], test pair [`ttest_pair']"
					reg `balancevar' `dummy_pair_`ttest_pair'' `covariates' i.`fixedeffect' `weight_option', `error_estm'

					*Number of observation for in these two groups
					mat row[1,`++colindex'] = e(N)
					*If clusters used, number of clusters in this these two groups, otehrwise .c
					local ++colindex
					if "`vce_type'" == "cluster" mat row[1,`colindex'] = e(N_clust)
					else mat row[1,`colindex'] = .c
				  *The diff between the groups after controling for fixed effects and covariates
					mat row[1,`++colindex'] = e(b)[1,1]

					*Perform the t-test and store p-value in pttest
					test `dummy_pair_`ttest_pair''
					mat row[1,`++colindex'] = r(p)
				}

				*Testing result and if valid, write to file with or without stars
				if `scal_sd' == 0 {

					local warn_means_num  	= `warn_means_num' + 1

					local warn_means_name`warn_means_num'	"Norm diff"
					local warn_means_group`warn_means_num' 	"(`first_group')-(`second_group')"
					local warn_means_bvar`warn_means_num'	"`balancevar'"

					* Adding missing value for no normdiff due to no standdev in balancevar for this pair
					mat row[1,`++colindex'] = .n

				}
				else {
					*Calculate and store the normalized difference
					mat row[1,`++colindex'] = el(row,1,colnumb(row,"diff_`ttest_pair'")) / `scal_sd'
				}
			}


		*** Test for joint orthogonality across all groups for this balance var
			* Run regression
			noi di "FEQ regression. Var [`balancevar']"
			reg `balancevar' i.`grpvar' `covariates' i.`fixedeffect' `weight_option', `error_estm'

			test `FEQTEST_INPUT'
			local pfeqtest 	= r(p)
			local ffeqtest 	= r(F)

			*Check if the test is valid. If not, print N/A and error message.
			*Is yes, print test
			if "`ffeqtest'" == "." {

				local warn_ftest_num  	= `warn_ftest_num' + 1
				local warn_ftest_bvar`warn_ftest_num'		"`balancevar'"

				* Adding missing values for invalid feq test
				mat row[1,`++colindex'] = .f
				mat row[1,`++colindex'] = .f
			}
			else {
				* Adding p value and F value to matrix
				mat row[1,`++colindex'] = `pfeqtest'
				mat row[1,`++colindex'] = `ffeqtest'
			}

			*Appending row for this balance var to result matrix
			mat `rmat' = [`rmat'\row]
		}

	/***********************************************
	***********************************************/

		*Running the regression for the F-tests

	/************************************************
	************************************************/

	*Local used to count number of f-test that trigered warnings
	local warn_joint_novar_num	0
	local warn_joint_lovar_num	0
	local warn_joint_robus_num	0
	local fmiss_error           0

	local Fcolindex             0

	*Run the F-test on each pair
	foreach ttest_pair of local TEST_PAIR_CODES {

		**********
		* Run the regression for f-test
		noi di "F regression. Var [`balancevars'], test pair [`ttest_pair']"
		reg `dummy_pair_`ttest_pair'' `balancevars' `covariates' i.`fixedeffect' `weight_option',  `error_estm'
		scalar reg_f = e(F)

		* Adding F score and number of observations to the matrix
		mat `fmat'[1,`++Fcolindex'] = e(N)

		*Test all balance variables for joint significance
		cap testparm `balancevars'
		scalar test_F = r(F)
		scalar test_p = r(p)

		**********
		* Write to table

		* No variance in either groups mean in any of the balance vars. F-test not possible to calculate
		if _rc == 111 {

			local warn_joint_novar_num	= `warn_joint_novar_num' + 1
			local warn_joint_novar`warn_joint_novar_num' "(`first_group')-(`second_group')"
		}

		* Collinearity between one balance variable and the dependent treatment dummy
		else if "`test_F'" == "." {

			local warn_joint_lovar_num	= `warn_joint_lovar_num' + 1
			local warn_joint_lovar`warn_joint_lovar_num' "(`first_group')-(`second_group')"
		}

		* F-test is incorreclty specified, error in this code
		else if _rc != 0 {

			noi di as error "F-test not valid. Please report this error to dimeanalytics@worldbank.org"
			error _rc
		}

		* F-tests possible to calculate
		else {

			* Robust singularity, see help file. Similar to overfitted model. Result possible but probably not reliable
			if "`reg_F'" == "." {

				local warn_joint_robus_num	= `warn_joint_robus_num' + 1
				local warn_joint_robus`warn_joint_robus_num' "(`first_group')-(`second_group')"
			}
			mat `fmat'[1,`++Fcolindex'] = test_F
			mat `fmat'[1,`++Fcolindex'] = test_p
		}
	}

	/*******************************************************************************
	*******************************************************************************/

			*Compile and display warnings from regressions and tests

	/*******************************************************************************
	*******************************************************************************/

	* Count if there were any warsnings generated above
	local anywarning	= max(`warn_means_num',`warn_ftest_num',`warn_joint_novar_num', `warn_joint_lovar_num' ,`warn_joint_robus_num')
	local anywarning_F	= max(`warn_joint_novar_num', `warn_joint_lovar_num' ,`warn_joint_robus_num')

	* Display warnings related to the pairwise test regressions
	if `anywarning' > 0 {

		noi di as text ""
		noi di as error "{hline}"
		noi di as error "{pstd}Stata issued one or more warnings in relation to the tests in this balance table. Read the warning(s) below carefully before using the values generated for this table.{p_end}"
		noi di as text ""

		if `warn_means_num' > 0 {

			noi di as text "{pmore}{bf:Difference-in-Means Tests:} The variance in both groups listed below is zero for the variable indicated and a difference-in-means test between the two groups is therefore not valid. Tests are reported as N/A in the table.{p_end}"
			noi di as text ""

			noi di as text "{col 9}{c TLC}{hline 11}{c TT}{hline 12}{c TT}{hline 37}{c TRC}"
			noi di as text "{col 9}{c |}{col 13}Test{col 21}{c |}{col 25}Group{col 34}{c |}{col 39}Balance Variable{col 72}{c |}"
			noi di as text "{col 9}{c LT}{hline 11}{c +}{hline 12}{c +}{hline 37}{c RT}"

			forvalues warn_num = 1/`warn_means_num' {
				noi di as text "{col 9}{c |}{col 11}`warn_means_name`warn_num''{col 21}{c |}{col 23}`warn_means_group`warn_num''{col 34}{c |}{col 37}`warn_means_bvar`warn_num''{col 72}{c |}"
			}
			noi di as text "{col 9}{c BLC}{hline 11}{c BT}{hline 12}{c BT}{hline 37}{c BRC}"
			noi di as text ""
		}

		if `warn_ftest_num' > 0 {

			noi di as text "{pmore}{bf:F-Test for Joint Orthogonality:} The variance all groups is zero for the variable indicated and a test of joint orthogonality for all groups is therefore not valid. Tests are reported as N/A in the table.{p_end}"
			noi di as text ""

			noi di as text "{col 9}{c TLC}{hline 25}{c TRC}"
			noi di as text "{col 9}{c |}{col 13} Balance Variable{col 35}{c |}"
			noi di as text "{col 9}{c LT}{hline 25}{c RT}"

			forvalues warn_num = 1/`warn_ftest_num' {
				noi di as text "{col 9}{c |}{col 12}`warn_ftest_bvar`warn_num''{col 35}{c |}"
			}
			noi di as text "{col 9}{c BLC}{hline 25}{c BRC}"
			noi di as text ""
		}

		* Display warnings related to the F test regression
		if `anywarning_F' > 0 {
			noi di as text "{pmore}{bf:Joint Significance Tests:} F-tests are not possible to perform or unreliable. See below for details:{p_end}"
			noi di as text ""

			if `warn_joint_novar_num' > 0 {

				noi di as text "{pmore}In the following tests, F-tests were not valid as all variables were omitted in the joint significance test due to collinearity. Tests are reported as N/A in the table.{p_end}"
				noi di as text ""

				noi di as text "{col 9}{c TLC}{hline 12}{c TRC}"
				noi di as text "{col 9}{c |}{col 13}Test{col 22}{c |}"
				noi di as text "{col 9}{c LT}{hline 12}{c RT}"

				forvalues warn_num = 1/`warn_joint_novar_num' {
					noi di as text "{col 9}{c |}{col 12}`warn_joint_novar`warn_num''{col 22}{c |}"
				}
				noi di as text "{col 9}{c BLC}{hline 12}{c BRC}"
				noi di as text ""
			}
			if `warn_joint_lovar_num' > 0 {

				noi di as text "{pmore}In the following tests, F-tests are not valid as the variation in, and the covariation between, the balance variables is too close to zero in the joint test. This could be due to many reasons, but is usually due to a balance variable with high correlation with group dummy. Tests are reported as N/A in the table.{p_end}"
				noi di as text ""

				noi di as text "{col 9}{c TLC}{hline 12}{c TRC}"
				noi di as text "{col 9}{c |}{col 13}Test{col 22}{c |}"
				noi di as text "{col 9}{c LT}{hline 12}{c RT}"

				forvalues warn_num = 1/`warn_joint_lovar_num' {
					noi di as text "{col 9}{c |}{col 12}`warn_joint_lovar`warn_num''{col 22}{c |}"
				}
				noi di as text "{col 9}{c BLC}{hline 12}{c BRC}"
				noi di as text ""
			}
			if `warn_joint_robus_num' > 0 {

				noi di as text "{pmore}In the following tests, F-tests are possible to calculate, but Stata issued a warning. Read more about this warning {help j_robustsingular:here}. Tests are reported with F-values and significance stars (if applicable), but these results might be unreliable.{p_end}"
				noi di as text ""

				noi di as text "{col 9}{c TLC}{hline 12}{c TRC}"
				noi di as text "{col 9}{c |}{col 13}Test{col 22}{c |}"
				noi di as text "{col 9}{c LT}{hline 12}{c RT}"

				forvalues warn_num = 1/`warn_joint_robus_num' {
					noi di as text "{col 9}{c |}{col 12}`warn_joint_robus`warn_num''{col 22}{c |}"
				}
				noi di as text "{col 9}{c BLC}{hline 12}{c BRC}"
				noi di as text ""
			}
		}

		noi di as error "{pstd}Stata issued one or more warnings in relation to the tests in this balance table. Read the warning(s) above carefully before using the values generated for this table.{p_end}"
		noi di as error "{hline}"
		noi di as text ""

	}

	/*******************************************************************************
	*******************************************************************************/

			*Prepare note string

	/*******************************************************************************
	*******************************************************************************/

	* Prepare the covariate note.
	if `COVARIATES_USED' == 1 {
		local covars_comma = ""

		*Loop over all covariates and add a comma
		foreach covar of local covariates {
			if "`covars_comma'" == "" {
				local covars_comma "and `covar'"
				local one_covar 1
			}
			else {
				local covars_comma "`covar', `covars_comma'"
				local one_covar 0
			}
		}

		* If only one covariate, remove and from local and make note singular, and if multiple covariates, make note plural.
		if `one_covar' == 1 {
			local covars_comma = subinstr("`covars_comma'" , "and ", "", .)
			local covar_note	"The covariate variable `covars_comma' is included in all estimation regressions. "
		}
		else {
			local covar_note	"The covariate variables `covars_comma' are included in all estimation regressions. "
		}
	}

	*** Prepare the notes used below
	local fixed_note	"Fixed effects using variable `fixedeffect' are included in all estimation regressions. "
	local stars_note	"***, **, and * indicate significance at the `p3star_percent', `p2star_percent', and `p1star_percent' percent critical level. "

	if `PTTEST_USED' == 1 {
		local ttest_note "The value displayed for t-tests are p-values. "
	}
	else {
		local ttest_note "The value displayed for t-tests are the differences in the means across the groups. "
	}

	if `PFTEST_USED' == 1 {
		local ftest_note "The value displayed for F-tests are p-values. "
	}
	else {
		local ftest_note "The value displayed for F-tests are the F-statistics. "
	}

	if `VCE_USED' == 1 {

		*Display variation in Standard errors (default) or in Standard Deviations
		if `STDEV_USED' == 0 {
			*Standard Errors string
			local 	variance_type_name 	"Standard errors"
		}
		else {
			*Standard Deviation string
			local 	variance_type_name 	"Standard deviations"
		}

		if "`vce_type'" == "robust"		local error_est_note	"`variance_type_name' are robust. "
		if "`vce_type'" == "cluster"  	local error_est_note	"`variance_type_name' are clustered at variable `cluster_var'. "
		if "`vce_type'" == "bootstrap"  local error_est_note	"`variance_type_name' are estimeated using bootstrap. "
	}

	if `WEIGHT_USED' == 1 {

		local f_weights "fweights fw freq weight"
		local a_weights "aweights aw"
		local p_weights "pweights pw"
		local i_weights "iweights iw"

		if `:list weight_type in f_weights' local weight_type = "frequency"
		else if `:list weight_type in a_weights' local weight_type = "analytical"
		else if `:list weight_type in p_weights' local weight_type = "probability"
		else if `:list weight_type in i_weights' local weight_type = "importance"

		local weight_note	"Observations are weighted using variable `weight_var' as `weight_type' weights."

	}


	if `BALMISS_USED' == 1 | `BALMISSREG_USED' == 1 {

		if `BALMISS_USED' 		== 1 	local balmiss_note "All missing values in balance variables are treated as zero."
		if `BALMISSREG_USED'  	== 1 	local balmiss_note "Regular missing values in balance variables are treated as zero,  {help missing:extended missing values} are still treated as missing."

		local BALMISS_USED = 1
	}



	if `COVMISS_USED' == 1 | `COVMISSREG_USED' == 1 {

		if `COVMISS_USED'		== 1	local covmiss_note "All missing values in covariate variables are treated as zero."
		if `COVMISSREG_USED'  	== 1	local covmiss_note "Regular missing values in covariate variables are treated as zero, {help missing:extended missing values} are still treated as missing."

		local COVMISS_USED = 1
	}

	*Restore from orginial preserve at top of command
	restore

	matrix `rmat' = `rmat'[2...,1...]

	mat returnRMat = `rmat'
	mat returnFMat = `fmat'

	return matrix iebaltabrmat returnRMat
	return matrix iebaltabfmat returnFMat



	/***********************************************
	************************************************/

		*Export tables from the matrix

	/*************************************************
	************************************************/

		******************************************
		*Export the data according to user specification

		noi di "export"

		*Set export locals

		** SE if standard errors are used (default)
		*  or SD if standard deviation is used
		if `STDEV_USED' == 1 	local vtype "sd"
		else local vtype "se"

		*N title
		if "`vce_type'" == "cluster" local ntitle "N/[Clusters]"
		else local ntitle "N"

		*********************
		* Pair test outputs

		* Use default value if none is specified by user
		if missing("`pairoutput'") local pout_val "diff"
		else local pout_val "`pairoutput'"

		* Prepare the pair test labels
		if "`pout_val'" == "diff" local pout_lbl "Mean difference"
		if "`pout_val'" == "beta" local pout_lbl "Beta coefficient"
		if "`pout_val'" == "nrmd" local pout_lbl "Normalized difference"
		if "`pout_val'" == "t" local pout_lbl "T-statistics" //todo: include in matrix
		if "`pout_val'" == "p" local pout_lbl "P-value"
		if "`pout_val'" == "none" local pout_lbl "none"


		*********************
		* test that option onerow is ok to use if used
		if (!missing("`onerow'")) isonerowok, mat(`rmat')

		***** Before using one_row - test the matrix that it is possible

		*Export to excel format
		if `SAVE_CSV_USED' | `SAVE_XSLX_USED' | `BROWSE_USED' {

			preserve
				// Run subommand that exports table to csv
				noi di "run export_tab"
				noi export_tab using `"`savecsv'"', ///
					rmat(`rmat') fmat(`fmat') ntitle("`ntitle'") vtype("`vtype'") ///
					note("The value displayed for t-tests are the differences in the means across the groups.") ///
					col_lbls(`COLUMN_LABELS') order_grp_codes(`ORDER_OF_GROUP_CODES') ///
					pairs(`TEST_PAIR_CODES')  ///
					row_lbls(`"`ROW_LABELS'"') `total' `onerow' tot_lbl("`tot_lbl'") ///
					pout_lbl(`pout_lbl') pout_val(`pout_val') diformat("`diformat'")

					tempfile tab_file
					save `tab_file'

					* Export the file in csv format
					if `SAVE_CSV_USED' {
						export delimited using "`savecsv'", novarnames quote `replace'
					}

					* Export the file in xlsx format
					if `SAVE_XSLX_USED' {
						export excel using "`savexlsx'", `replace'
					}

			restore
		}

		* Browse the results in the output window. This overwrites data in memory
		if `BROWSE_USED' {
			use `tab_file', clear
		}


		// *Export to tex format
		// if `SAVE_TEX_USED' {
		// 	// Run subommand that exports table to tex
		// }
}
end


/*******************************************************************************

  Function to get and test the two codes in a test pair
	pair 4_12 returns rlocal code1 = 4, and rlocal code2 = 12

*******************************************************************************/
cap program drop 	getCodesFromPair
	program define	getCodesFromPair, rclass

	args pair

	* Parse the two codes from the test pair
	local undscr_pos  = strpos("`pair'","_")
	local code1 = substr("`pair'",1,`undscr_pos'-1)
	local code2 = substr("`pair'",  `undscr_pos'+1,.)

	*Test that the codes are just numbers and that they are not identical
	cap confirm number `code1'`code2'
	if _rc {
		noi display as error "{phang}Both codes [`code1'] & [`code2'] in pair [`pair'] must be numbers.{p_end}"
		error 7
	}
	if `code1' == `code2' {
		noi display as error "{phang}The codes in [`pair'] may not be identical.{p_end}"
		error 7
	}

    * Return second first so they are listed in correct order
	* when using return list
	return local code2 `code2'
	return local code1 `code1'

end

/*******************************************************************************

  Function that oupputs the result matrix to csv file

*******************************************************************************/

cap program drop 	export_tab
	program define	export_tab, rclass

	syntax using , rmat(name) fmat(name) 					///
	ntitle(string) vtype(string) note(string)		///
	col_lbls(string) order_grp_codes(numlist) ///
	pairs(string) diformat(string) ///
	row_lbls(string) tot_lbl(string) ///
	pout_lbl(string) pout_val(string) ///
	[onerow total]

	//noi di "insdie export_tab"

	noi mat list `rmat'
	noi mat list `fmat'

	local grp_count : list sizeof order_grp_codes
	local row_count : list sizeof row_lbls

	*Create a temporary textfile
	tempname 	tab_name
	tempfile	tab_file

	******************************************************************************
	* Generate title rows
	******************************************************************************

	** The titles consist of three rows across all
	*  columns of the table. Each row is one local
	local titlerow1 ""
	local titlerow2 ""
	local titlerow3 `""Variable""'

	********* Descriptive group stats titles *************************************
	*Loop over each group to be used in descriptive stats section

	forvalues grp_colnum = 1/`grp_count' {

		*Get the code and label corresponding to the group
		local grp_lbl : word `grp_colnum' of `col_lbls'

		*Titles for each group depending on the option one row used or not
		if missing("`onerow'") {
			local titlerow1 `"`titlerow1' _tab "" "'
			local titlerow2 `"`titlerow2' _tab "" "'
			local titlerow3 `"`titlerow3' _tab "`ntitle'" "'
		}

		*Add titles for summary row stats
		local titlerow1 `"`titlerow1' _tab " (`grp_colnum') " "'
		local titlerow2 `"`titlerow2' _tab "`grp_lbl'"        "'
		local titlerow3 `"`titlerow3' _tab "Mean/`vtype'"     "'
	}

	********* Descriptive full sample stats title ********************************

	if !missing("`total'") {
		* Calcualte total column number
		local tot_colnum = `grp_count' + 1

		*Create one more column for N if N is displayed in column instead of row
		if missing("`onerow'") {
			local titlerow1 `"`titlerow1' _tab "" "'
			local titlerow2 `"`titlerow2' _tab "" "'
			local titlerow3 `"`titlerow3' _tab "`ntitle'" "'
		}

		*Add titles for summary row stats
		local titlerow1 `"`titlerow1' _tab " (`tot_colnum') " "'
		local titlerow2 `"`titlerow2' _tab "`tot_lbl'"        "'
		local titlerow3 `"`titlerow3' _tab "Mean/`vtype'"     "'
	}

	********* Test pairs titles **************************************************

	foreach pair of local pairs {

		*Get each code from a testpair
		getCodesFromPair `pair'
		local code1 `r(code1)'
		local code2 `r(code2)'

		*Write test pair titles
		local titlerow1 `"`titlerow1' _tab "Pairwise t-test""'
		local titlerow2 `"`titlerow2' _tab "`pout_lbl'""'
		local titlerow3 `"`titlerow3' _tab "(`code1')-(`code2')""'
	}

	********* Write the title lines **********************************************

	*Write the title rows defined above
	cap file close 	`tab_name'
	file open  		`tab_name' using "`tab_file'", text write replace
	file write  	`tab_name' `titlerow1' _n `titlerow2' _n `titlerow3' _n
	file close 		`tab_name'

	******************************************************************************
	* Write data rows
	******************************************************************************

	forvalues row_num = 1/`row_count' {

		*Get the code and label corresponding to the group
		local row_lbl : word `row_num' of `row_lbls'

		********* Initiate row locals and write row label **************************

		*locals for each row
		local row_up   `""`row_lbl'""'
		local row_down `""' // Not used in onerow

		********* Write group descriptive stats ************************************

		foreach grp_code of local order_grp_codes {

			* Add column with N for this group unless option onerow is used
			if missing("`onerow'") {
				local n_value = el(`rmat',`row_num',colnumb(`rmat',"n_`grp_code'"))
				local row_up   `"`row_up'   _tab "`n_value'" "'
				local row_down `"`row_down' _tab "" "'
			}

			* Mean and variance for this group - get value from mat and apply format
			local mean_value = el(`rmat',`row_num',colnumb(`rmat',"mean_`grp_code'"))
			local var_value = el(`rmat',`row_num',colnumb(`rmat',"`vtype'_`grp_code'"))
			local mean_value : display `diformat' `mean_value'
			local var_value  : display `diformat' `var_value'
			local row_up   `"`row_up'   _tab "`mean_value'" "'
			local row_down `"`row_down' _tab "`var_value'" "'
		}

		********* Write total smaple stats *****************************************

		if !missing("`total'") {

			* Add column with N for this group unless option onerow is used
			if missing("`onerow'") {
				local n_value = el(`rmat',`row_num',colnumb(`rmat',"n_t"))
				local row_up   `"`row_up'   _tab "`n_value'" "'
				local row_down `"`row_down' _tab "" "'
			}

			* Mean and variance for this group - get value from mat and apply format
			local mean_value = el(`rmat',`row_num',colnumb(`rmat',"mean_t"))
			local var_value = el(`rmat',`row_num',colnumb(`rmat',"`vtype'_t"))
			local mean_value : display `diformat' `mean_value'
			local var_value  : display `diformat' `var_value'
			local row_up   `"`row_up'   _tab "`mean_value'" "'
			local row_down `"`row_down' _tab "`var_value'" "'
		}

		********* Write pair test stats ********************************************

		foreach pair of local pairs {
			* Pairwise test statistics for this pair - get value from mat and apply format
			local test_value = el(`rmat',`row_num',colnumb(`rmat',"`pout_val'_`pair'"))
			local test_value 	: display `diformat' `test_value'
			local row_up   `"`row_up'   _tab "`test_value'" "'
			local row_down `"`row_down' _tab "" "'
		}

		********* Write row locals *************************************************

		*Write the title rows defined above
		cap file close 	`tab_name'
		file open  		`tab_name' using "`tab_file'", text write append
		file write  	`tab_name' `row_up' _n `row_down' _n
		file close 		`tab_name'
	}

	******************************************************************************
	* Write onerow N (if applicable)
	******************************************************************************

	if !missing("`onerow'") {

		*Initiate the row local for the N row if onerow is not missing
		local n_row `""Number of observations""'

		*Get the N for each group
		foreach grp_code of local order_grp_codes {
			* Get the N from the first row (they must be the same for onerow to work)
			local n_value = el(`rmat',1,colnumb(`rmat',"n_`grp_code'"))
			local n_row   `"`n_row' _tab "`n_value'" "'
		}

		*If total was used, add the N from the first row
		if !missing("`total'") {
			local n_value = el(`rmat',1,colnumb(`rmat',"n_t"))
			local n_row   `"`n_row' _tab "`n_value'" "'
		}

		*Get the N from each pair
		foreach pair of local pairs {
			local n_value = el(`rmat',1,colnumb(`rmat',"tn_`pair'"))
			local n_row   `"`n_row' _tab "`n_value'" "'
		}

		*Write the N row to file
		cap file close 	`tab_name'
		file open  		`tab_name' using "`tab_file'", text write append
		file write  	`tab_name' `n_row' _n
		file close 		`tab_name'
	}

	******************************************************************************
	* Write footer
	******************************************************************************

	*Write the title rows defined above
	cap file close 	`tab_name'
	file open  		`tab_name' using "`tab_file'", text write append
	file write  	`tab_name' "`note'" _n
	file close 		`tab_name'

	******************************************************************************
	* Import tabfile to memory
	******************************************************************************

	* Import tab file to memory to be exported as csv, xlsx or be browsed.
	* Tabs are used as they are never used in labels, making manual writing easier
	insheet using "`tab_file'", tab clear

end


/*******************************************************************************

  Function that oupputs the result matrix to tex file

*******************************************************************************/

cap program drop 	export_tex
	program define	export_tex

	syntax using , rmat(name) fmat(name) [note(string)]

	noi mat list `rmat'
	noi mat list `fmat'

end

********************************************************************************
*  Function that tests if each n_ column in the matrix has the same value for
*	 all rows so that the N can be displayed on one row at the botton of the table
cap program drop 	isonerowok
	program define	isonerowok

	syntax , mat(name)

	local not_ok_grps ""

	* Get all column names that starts on n_, i.e. all cols with N
	local all_cnames : colnames `mat'
	local ncnames ""
	foreach cname of local all_cnames {
		if substr("`cname'",1,2) == "n_" local ncnames "`ncnames' `cname'"
	}
	//Remove total from test, as if all groups are the same, then total is the same
	local ncnames = subinstr("`ncnames'","n_t","",1)

	*Get number of rows
	local matrows  : rowsof `mat'
	*If matrix only has one row, then onerow is always ok
	if `matrows' > 1 {
		*Test if all values are the same in all n columns
		foreach ncname of local ncnames {
			local nval = el(`mat',1,colnumb(`mat',"`ncname'"))
			forvalues row = 2/`matrows' {
				if `nval' != el(`mat',`row',colnumb(`mat',"`ncname'")) {
					local not_ok_grps : list not_ok_grps | ncname
				}
			}
		}
	}

	if ("`not_ok_grps'" != "") {
		local not_ok_grps = subinstr("`not_ok_grps'","n_","",.)
		local not_ok_grps : list sort not_ok_grps
		noi di as error "{pstd}Option {input:onerow} may only be used if the number of observations with non-missing values are the same in all groups across all balance variables. This is not true for group(s): [`not_ok_grps'].{p_end}"
		error 499
	}
end
