Parameter cWhere

lcWhere = ''
lcWhere = IIF(EMPTY(fltrAruanne.kond),' rekv_id = ' + STR(gRekv), '')


TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT


lError = oDb.readFromModel('aruanned\raamatupidamine\kaibeasutusandmik', 'kaibeasutusandmik_report',; 
	'ALLTRIM(fltrAruanne.konto), fltrAruanne.asutusid, fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Kaibeasutusandmik')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT rekv_id, asutus_id, konto, nimetus, alg_saldo, deebet, kreedit, lopp_saldo,;
	asutus, regkood, tp ;
	FROM tmpReport ;
	ORDER BY asutus, konto, rekv_id ;
	INTO CURSOR KaibeAsutusAndmik_report1

USE IN tmpReport

SELECT KaibeAsutusAndmik_report1
