Parameter tcWhere
lcWhere = ' 1=1 '
lcWhere = lcWhere  + Iif(Empty(fltrAruanne.kond),' and qry.rekv_id = ' + Str(gRekv), '')


TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	and konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
	and tunnus ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
ENDTEXT


lError = oDb.readFromModel('aruanned\raamatupidamine\kontosaldoandmik_tunnus_tt', 'kontosaldoandmik_report', 'alltrim(fltrAruanne.konto),fltrAruanne.asutusid, fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Konto saldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif


Select * From tmpReport ;
	ORDER By tmpReport.rekv_id, konto, asutus ;
	INTO Cursor kaibeAsutusandmik_report1
	
Use In tmpReport

Select kaibeAsutusandmik_report1