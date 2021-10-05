
	/*******************************************************************************
	  Set up
	*******************************************************************************/

	* Load the version in this clone into memory. If you need to use the version
	* currently installed in you instance of Stata, then simply re-start Stata.
	* Set up the ietoolkit_clone global root path in ietoolkit\run\run_master.do
	qui do "${ietoolkit_clone}/src/ado_files/iesave.ado"

	*Load utility function that helps clean up folders inbetween test runs
	qui do "${ietoolkit_clone}/run/ie_recurse_rmdir.do"

	*Load utility function that helps create folders inbetween test runs
	qui do "${ietoolkit_clone}/run/ie_recurse_mkdir.do"

	*Path to test output folder
	local test_folder "${runoutput}/iesave"

	/*******************************************************************************
		Run this run file once for each save file version
	*******************************************************************************/
  * Only include the version your Stata version can run
	if 			`c(stata_version)' < 13 local stata_versions 12
	else if `c(stata_version)' < 14 local stata_versions 12 13
	else                            local stata_versions 12 13 14

	foreach stata_ver of local stata_versions {

		*Delete any content from previous round
		ie_recurse_rmdir, folder("`test_folder'") okifnotexist

		* Create the output folder (and all its parents is needed)
		ie_recurse_mkdir, folder("`test_folder'")

		*Lsit of all files this run file is expected to create
		local expected_files ""

	/*******************************************************************************
		Options: No error
	*******************************************************************************/

		/*********************
		      IDvars
		*********************/

		* single id
		sysuse auto, clear
		iesave using "`test_folder'/id_1.dta", 	///
			idvars(make) 													///
			saveversion(`stata_ver') 							///
			replace

		*Add this file to list of expected files
		local expected_files `"`expected_files' "id_1.dta""'

		* idvars list
		sysuse auto, clear
	  gen id = make
		iesave using "`test_folder'/id_2.dta", 	///
			idvars(make id) 											///
			saveversion(`stata_ver') 							///
			replace

		*Add this file to list of expected files
		local expected_files `"`expected_files' "id_2.dta""'

		* Missing values in the idvars
		sysuse auto, clear
		gen id = _n if _n != 74

		cap iesave using "`test_folder'/err_id_1.dta", 	///
			idvars(id) replace 														///
			saveversion(`stata_ver')

		assert _rc == 459

		* Duplicates in the idvars
		sysuse auto, clear
		gen id = _n
		replace id = 3 in 4
		replace id = 8 in 11
		replace id = 8 in 21

		cap iesave using "`test_folder'/err_id_2.dta", 	///
			idvars(id) replace												///
			saveversion(`stata_ver')

		assert _rc == 459

		/*********************
		      varreport
		*********************/

		sysuse auto, clear
		iesave using "`test_folder'/rep_1.dta",	///
			idvars(make) replace 									///
			saveversion(`stata_ver') 							///
			varreport("`test_folder'/rep_1.csv") 	///
			reportreplace

		*Add these files to list of expected files
		local expected_files `"`expected_files' "rep_1.dta" "rep_1.csv""'

		/*********************
		      missing reportreplace
		*********************/
		sysuse auto, clear

		cap iesave using "`test_folder'/err_nomiss_1.dta",	///
			idvars(make) saveversion(`stata_ver')			///
			varreport("`test_folder'/rep_1.csv")			///
			replace
		assert _rc == 601


		/*********************
		      VNOMissing
		*********************/
		sysuse auto, clear
		cap iesave using "`test_folder'/err_nomiss_2.dta",	///
			idvars(make) 																	///
			saveversion(`stata_ver') 											///
			vnomissing(headroom trunk rep78)
		assert _rc == 416


		/*********************
		   VNOSTANDMissing
		*********************/
		sysuse auto, clear
		replace trunk = .d in 12
		replace trunk = .n in 13
		replace trunk = .a in 14
		replace trunk = . in 11

		cap iesave using "`test_folder'/err_nomiss_3.dta",	///
			idvars(make) saveversion(`stata_ver') 				///
			vnostandmissing(headroom trunk rep78)
		assert _rc == 416


		/*********************
		   userinfo
		*********************/

		sysuse auto, clear
		iesave using "`test_folder'/user_1.dta",	///
			idvars(make) replace										///
			saveversion(`stata_ver') 								///
			userinfo

		*Add these files to list of expected files
		local expected_files `"`expected_files' "user_1.dta""'

	/*******************************************************************************
	    * Invalid syntaxes
	*******************************************************************************/

		*****************
		* missing using
		sysuse auto, clear
		cap iesave
		assert _rc == 100

		*****************
		* idvars and saveversion required options
		sysuse auto, clear
		cap iesave using "`test_folder'/err_syntax_1.dta"
		assert _rc == 198

		sysuse auto, clear
		cap iesave using "`test_folder'/err_syntax_2.dta", saveversion(`stata_ver')
		assert _rc == 198

		sysuse auto, clear
		cap iesave using "`test_folder'/err_syntax_3.dta", idvars(make)
		assert _rc == 198


	  *****************
		* incorrect .dta version value
		cap iesave using "`test_folder'/err_syntax_4.dta", idvars(make) saveversion(18)
		assert _rc == 198

		*****************
		* reportreplace may only be used with varreport
		cap iesave using "`test_folder'/err_syntax_5.dta", ///
			idvars(make) saveversion(`stata_ver') 		///
			reportreplace
		assert _rc == 198

		*****************
		* missing report file extension AND bad path
		cap iesave using "`test_folder'/err_syntax_6.dta",	///
			idvars(make) saveversion(`stata_ver') 		///
			varreport("`test_folder'/report1")
		assert _rc == 601

		* folder don´t exist
		cap iesave using "`test_folder'/err_syntax_7.dta",	///
		 	idvars(make) saveversion(`stata_ver') 			///
			varreport("FOLDER-THAT-DSOES-NOT-EXIST/report1.csv")
		assert _rc == 601


	********************************************************************************
		* Testing char values *
	********************************************************************************

		/*****************************************
		Validate if char values are as expected
		*****************************************/

		sysuse auto, clear

		*1. Run iesave
		iesave using "`test_folder'/char_1.dta", ///
			idvars(make) saveversion(`stata_ver') replace userinfo

		*Add these files to list of expected files
		local expected_files `"`expected_files' "char_1.dta""'

		*2. Store char values in locals
		foreach value in idvars N username computerid datasignature timesave {
			//display 	 "`value' : " r(`value')
			local	 char_`value' : char _dta[iesave_`value']
		}

		*3. Open the dataset just saved
		use "`test_folder'/char_1.dta", clear
		qui datasignature
		local datasig `r(datasignature)'

		*4. Validate if char values are non-missing and as expected
		assert !missing("`char_idvars'")
		assert !missing("`char_N'")
		assert !missing("`char_username'")
		assert !missing("`char_computerid'")
		assert !missing("`char_datasignature'")

		assert "`char_idvars'" 				== "make"
		assert  `char_N'  						== _N
		assert "`char_username'" 			== "`c(username)'"
		assert "`char_computerid'"		== "`c(hostname)'"
		assert "`char_datasignature'"	== "`datasig'"

		*Make sure that time saved in char is less than time after sleeping for 3 sec
		sleep 3000
		assert Clock("`char_timesave'", "hmsDMY") < ///
					 Clock("`c(current_time)' `c(current_date)'", "hmsDMY")

		/**************************************************************
		Validate if char values are as expected after make data changes
		***************************************************************/

		sysuse auto, clear
		drop if trunk > 22
		drop displacement
		iesave using "`test_folder'/char_2.dta", ///
			idvars(make) saveversion(`stata_ver') replace userinfo

		*Add these files to list of expected files
		local expected_files `"`expected_files' "char_2.dta""'

		di `" assert "`char_idvars'" 				== "`: char _dta[iesave_idvars]'" "'
		di `" assert "`char_username'" 			== "`: char _dta[iesave_username]'" "'
		di `" assert "`char_computerid'"		== "`: char _dta[iesave_computerid]'" "'
		di `" assert "`char_datasignature'"	!= "`: char _dta[iesave_datasignature]'" "'

		assert "`char_idvars'" 				== "`: char _dta[iesave_idvars]'"
		assert "`char_username'" 			== "`: char _dta[iesave_username]'"
		assert "`char_computerid'"		== "`: char _dta[iesave_computerid]'"
		assert "`char_datasignature'"	!= "`: char _dta[iesave_datasignature]'"

		/**************************************************************
		Test that only the exact data sets expected are created
		***************************************************************/

		*List files in output folder and remove the double qoutes
		local files_in_folder : dir `"`test_folder'"' files "*"	, respectcase

		*Get list of missing and extra files
		local missing_files : list expected_files - files_in_folder
		local extra_files : list files_in_folder - expected_files

		*Output error if there were extra or missing files
		if `"`missing_files'"' != "" {
			noi di as error `"{phang}The following files were expecetd to be creaetd by this run0file but they were not created [`missing_files']{p_end}"'
			error 9
		}
		if `"`extra_files'"' != "" {
			noi di as error `"{phang}The following files were not expecetd to be creaetd by this run-file but they were created [`extra_files']{p_end}"'
			error 9
		}
	}

***************************** End of do-file ***********************************
