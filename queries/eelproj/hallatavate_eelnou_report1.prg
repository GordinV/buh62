Parameter cWhere

Wait Window 'Päring...' Nowait

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and 	coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'

ENDTEXT

lError = oDb.readFromModel('aruanned\eelarve\hallatavate_eelnou', 'hallatavate_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond, fltrAruanne.taotlus_statusid', 'hallatavate_eelnou_report1',lcWhere )

If !lError Or !Used('hallatavate_eelnou_report1')
	Messagebox('Viga',0+16, 'Hallatavate eelarve eelnõu')
	Set Step On
	Select 0
	Return .F.
Endif

Select hallatavate_eelnou_report1
