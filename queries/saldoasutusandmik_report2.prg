Parameter tcWhere
lcWhere = '1 = 1'
lcWhere = lcWhere  + Iif(Empty(fltrAruanne.kond),' AND qry.rekv_id = ' + Str(gRekv), '')

TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	AND LEFT(konto,6) in ('102060','102070','102081','102090','102095','103000','103010',
	'201000','201010','203900','203910','203990') 
ENDTEXT

IF !EMPTY(fltrAruanne.konto) 
TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	and konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT
ENDIF



l_konto = null
lError = oDb.readFromModel('aruanned\raamatupidamine\kontosaldoandmik', 'kontosaldoandmik_report', 'l_konto,fltrAruanne.asutusid, fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Konto saldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif


Select sum(r.saldo) as saldo, asutus_id;
	From tmpReport r;
	GROUP BY asutus_id;
	INTO Cursor tmpKaibed


Select r.saldo, a.nimetus as asutus, a.regkood, a.aadress   ;
	From tmpKaibed r;
	INNER JOIN comAsutusRemote a ON a.id = r.asutus_id;
	ORDER By a.nimetus, a.regkood ;
	INTO Cursor KaibeAsutusAndmik_report1
	
Use In tmpReport
USE IN tmpKaibed

Select kaibeAsutusandmik_report1
