Parameter cWhere
* Eelarve kulude tegevusalade ja majanduliku sisu järgi

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
ENDTEXT


lError = oDb.readFromModel('aruanned\eelarve\kassa_taitmine', 'kassa_taitmine', ' fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kassatäitmine')
	Set Step On
	Select 0
	Return .F.
Endif

Select tegev, artikkel, nimetus, Sum(eelarve) As eelarve, Sum(taitmine) As taitmine, idx ;
	from tmpReport ;
	GROUP By idx, tegev, artikkel, nimetus;
	ORDER By idx, tegev, artikkel, nimetus;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2
