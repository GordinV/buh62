Parameter cWhere

l_kond = fltrAruanne.kond

lcWhere = ''

TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT

TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrAruanne.konto),'Konto=','')>> <<ALLTRIM(fltrAruanne.konto)>> <<IIF(!EMPTY(fltrAruanne.konto),'%','')>>
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.tunnus),IIF(LEN(l_params)> 0 ,', ','') + 'Tunnus=','')>> <<ALLTRIM(fltrAruanne.tunnus)>> <<IIF(!EMPTY(fltrAruanne.tunnus),'%','')>>
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.proj),IIF(LEN(l_params)> 0 ,', ','') + 'Projekt=','')>> <<ALLTRIM(fltrAruanne.proj)>> <<IIF(!EMPTY(fltrAruanne.proj),'%','')>>
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.uritus),IIF(LEN(l_params)> 0 ,', ','') + '�ritus=','')>> <<ALLTRIM(fltrAruanne.uritus)>> <<IIF(!EMPTY(fltrAruanne.uritus),'%','')>>
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.objekt),IIF(LEN(l_params)> 0 ,', ','') + 'Objekt=','')>> <<ALLTRIM(fltrAruanne.objekt)>> <<IIF(!EMPTY(fltrAruanne.objekt),'%','')>> 
ENDTEXT


If !Used('fltrParametid')
	Create Cursor fltrParametid (params m)
	Append Blank
Endif

Replace fltrParametid.params With l_params In fltrParametid

l_tunnus = ''

TEXT TO l_params TEXTMERGE noshow
	{
		"tunnus":"<<ALLTRIM(fltrAruanne.tunnus)>>",
		"konto":"<<ALLTRIM(fltrAruanne.konto)>>",
		"proj":"<<ALLTRIM(fltrAruanne.proj)>>",
		"uritus":"<<ALLTRIM(fltrAruanne.uritus)>>",
		"objekt":"<<ALLTRIM(fltrAruanne.objekt)>>"
	}
ENDTEXT

lError = oDb.readFromModel('aruanned\raamatupidamine\kaibeasutusandmik', 'kaibeasutusandmik_report',; 
	'ALLTRIM(fltrAruanne.konto), fltrAruanne.asutusid, fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv,l_tunnus ,l_kond,l_params', 'KaibeAsutusAndmik_report1', lcWhere)
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