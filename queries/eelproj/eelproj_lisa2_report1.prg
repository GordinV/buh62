Parameter tcWhere

lcWhere = .f.
IF !EMPTY(fltrAruanne.asutusid)
	TEXT TO lcWhere TEXTMERGE noshow
		rekv_id = <<fltrAruanne.asutusid>>
	ENDTEXT
ENDIF


lError = oDb.readFromModel('aruanned\eelarve\lisa_2', 'lisa_2', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Lisa 2')
	Set Step On
	Select 0
	Return .F.
Endif

Select * ;
	from tmpReport r;
	ORDER By r.rekv_id;
	INTO Cursor eelarve_report1

Use In tmpReport
Select eelarve_report1

