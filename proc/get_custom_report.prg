PARAMETERS t_report, is_coping
LOCAL l_start_folder, l_custom_folder, l_source_report, l_custom_report, l_return_file

l_return_file = t_report

l_start_folder = SYS(5)+CURDIR()
l_custom_folder = l_start_folder + 'custom\'

* report file located in reports catalog + t_report
* 1. full report source file
* 2. full report destination file
* 3. dist. folder if not exists , create
* 4. copy

l_source_report = l_start_folder + 'reports\' + t_report

IF !FILE(l_source_report + '.frx')
	MESSAGEBOX('Puudub report file',0+1,'Report muutmine')
	RETURN .f.
ENDIF

* 2. full report destination file
l_custom_report = l_custom_folder + t_report

* 3. dist. folder if not exists , create

IF !DIRECTORY(l_custom_folder) AND is_coping
	mkdir l_custom_folder
	mkdir l_custom_folder + '\arveldused'
	mkdir l_custom_folder + '\eelarve'
	mkdir l_custom_folder + '\ladu'
	mkdir l_custom_folder + '\pv'
	mkdir l_custom_folder + '\eelproj'
	mkdir l_custom_folder + '\hooldekodu'
	mkdir l_custom_folder + '\kassa'
	mkdir l_custom_folder + '\ou'
	mkdir l_custom_folder + '\palk'
	mkdir l_custom_folder + '\reklmaks'
	mkdir l_custom_folder + '\saldoandmik'
	
ENDIF

* 4. copy

IF !FILE(l_custom_report + '.frx') AND is_coping
	COPY FILE (l_source_report + '.frx') TO (l_custom_report + '.frx')
	COPY FILE (l_source_report + '.frt') TO (l_custom_report + '.frt')
ENDIF


IF FILE(l_custom_report + '.frx')
	return l_custom_report
ELSE
	RETURN l_return_file
ENDIF


