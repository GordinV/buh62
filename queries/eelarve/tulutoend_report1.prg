Parameter cWhere

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekvid = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekvid = <<gRekv>>
	ENDTEXT
ENDIF
l_kpv1 = fltrAruanne.kpv1
l_kpv2 = fltrAruanne.kpv2

lError = oDb.readFromModel('aruanned\eelarve\tulutoend', 'tulutoend_report', 'l_kpv1,l_kpv2,gRekv', 'tulutoend_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve tulutoend')
	Set Step On
	Select 0
	Return .F.
Endif
Select tulutoend_report1

