Parameter cWhere

IF USED('tmpReport')
	USE IN tmpReport
ENDIF


lcWhere = ''
lcWhere = IIF(EMPTY(fltrAruanne.kond),' rekv_id = ' + STR(gRekv), '')


TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT


lError = oDb.readFromModel('aruanned\raamatupidamine\kaibeandmik', 'kaibeandmik_report', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Kaibeandmik')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT alg_db as algdb, alg_kr as algkr, deebet, kreedit, lopp_db as loppdb, lopp_kr as loppkr,;
	konto, nimetus, rekv_nimi,;
	LEFT(konto,IIF(LEFT(konto, 6) = '100100', 6,IIF(LEFT(konto,3) = '500', 3,Len(Alltrim(konto)) - Round(Len(Alltrim(konto))/2,0)))) as pohikonto;
	FROM tmpReport ;
	WHERE alg_db <> 0 OR  alg_kr <> 0 OR deebet <> 0 OR kreedit <> 0 OR lopp_db <> 0 OR lopp_kr <> 0 ;
	order by konto, rekv_nimi ;
	INTO CURSOR kaibeandmik_report1

USE IN 	tmpReport

SELECT kaibeandmik_report1
