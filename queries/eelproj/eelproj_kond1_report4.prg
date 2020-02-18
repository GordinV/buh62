Parameter tcWhere
lcWhere = ''

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
ENDTEXT

lError = oDb.readFromModel('aruanned\eelarve\tegev_eelnou', 'tegev_eelnou', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve t�itmine')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT * ;
	from tmpReport ;
	ORDER BY  tegev, parentAsutus, asutus ; 
	INTO Cursor eelarve_report1


Use In tmpReport
Select eelarve_report1

