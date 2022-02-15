Parameter cWhere

Wait Window 'Päring...' Nowait

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
ENDTEXT


TEXT TO lcAllikas TEXTMERGE noshow
	{"allikas":"LE-P"}
ENDTEXT


lError = oDb.readFromModel('aruanned\eelarve\kulud_eelnou', 'kulud_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond,lcAllikas ', 'tulud_eelnou_report1',lcWhere )

If !lError OR !USED('tulud_eelnou_report1')
	Messagebox('Viga',0+16, 'Kulud eelarve eelnõu')
	Set Step On
	Select 0
	Return .F.
ENDIF

SELECT tulud_eelnou_report1
