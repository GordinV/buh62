Parameter cWhere

Wait Window 'P�ring...' Nowait

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
ENDTEXT

lError = oDb.readFromModel('aruanned\eelarve\tulud_eelnou', 'tulud_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond', 'tulud_eelnou_report1',lcWhere )

If !lError OR !USED('tulud_eelnou_report1')
	Messagebox('Viga',0+16, 'Tulud eelarve eeln�u')
	Set Step On
	Select 0
	Return .F.
ENDIF

SELECT tulud_eelnou_report1