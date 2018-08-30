Parameter tcWhere
lcWhere = ''
lcWhere = Iif(Empty(fltrAruanne.kond),' qry.rekv_id = ' + Str(gRekv), '')

TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> ( konto in ('103701','103950','103009','203900','200060') or left(ltrim(rtrim(konto)),3) = ('201'))
ENDTEXT

l_konto = null
lError = oDb.readFromModel('aruanned\raamatupidamine\kontosaldoandmik', 'kontosaldoandmik_report', 'l_konto,fltrAruanne.asutusid, fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Konto saldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif


Select sum(r.saldo) as saldo, asutus, regkood, aadress   ;
	From tmpReport r;
	ORDER By asutus, regkood, aadress ;
	GROUP BY asutus, regkood, aadress ;
	INTO Cursor KaibeAsutusAndmik_report1
	
Use In tmpReport

Select kaibeAsutusandmik_report1
