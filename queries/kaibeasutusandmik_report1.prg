Parameter cWhere

l_kond = fltrAruanne.kond

lcWhere = ''


TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT

l_tunnus = '%'
IF (!EMPTY(fltrAruanne.tunnus))
	l_tunnus = ALLTRIM(fltrAruanne.tunnus) + '%'
ENDIF


TEXT TO l_params TEXTMERGE noshow
	{
		"tunnus":"<<ALLTRIM(fltrAruanne.tunnus)>>",
		"konto":"<<ALLTRIM(fltrAruanne.konto)>>",
		"proj":"<<ALLTRIM(fltrAruanne.proj)>>",
		"uritus":"<<ALLTRIM(fltrAruanne.uritus)>>"
	}
ENDTEXT

lError = oDb.readFromModel('aruanned\raamatupidamine\kaibeasutusandmik', 'kaibeasutusandmik_report',; 
	'ALLTRIM(fltrAruanne.konto), fltrAruanne.asutusid, fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv,l_tunnus,l_kond,l_params', 'KaibeAsutusAndmik_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'KaibeAsutusAndmik_report1')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

*!*	SELECT rekv_id, asutus_id, konto, nimetus, alg_saldo, deebet, kreedit, lopp_saldo,;
*!*		asutus, regkood, tp, rekv_nimetus ;
*!*		FROM tmpReport ;
*!*		ORDER BY rekv_id,  konto, asutus  ;
*!*		INTO CURSOR KaibeAsutusAndmik_report1

*!*	USE IN tmpReport

SELECT KaibeAsutusAndmik_report1