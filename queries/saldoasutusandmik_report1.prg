Parameter tcWhere
lcWhere = ''
lcWhere = Iif(Empty(fltrAruanne.kond),' qry.rekv_id = ' + Str(gRekv), '')
l_kond = fltrAruanne.kond


TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT


lError = oDb.readFromModel('aruanned\raamatupidamine\kontosaldoandmik', 'kontosaldoandmik_report', 'alltrim(fltrAruanne.konto),fltrAruanne.asutusid, fltrAruanne.kpv2, gRekv,l_kond', 'kaibeAsutusandmik_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Konto saldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif

Select kaibeAsutusandmik_report1
