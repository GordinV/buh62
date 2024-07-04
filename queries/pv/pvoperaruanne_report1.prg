Parameter cWhere


TEXT TO lcWhere TEXTMERGE noshow
	rekv_id = <<gRekv>>
	and konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT

IF !EMPTY(fltrAruanne.grupp)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and grupp_id = <<fltrAruanne.grupp>>
	ENDTEXT
ENDIF



IF !EMPTY(fltrAruanne.asutusid)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and vastisik_id = <<fltrAruanne.asutusid>>
	ENDTEXT
ENDIF


lError = oDb.readFromModel('aruanned\pv\pv_oper_aruanne', 'pv_oper_aruanne_report', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'PV aruanne')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT * ;
from tmpReport ;
ORDER BY grupp, pvkood, kpv;
INTO CURSOR pvoperaruanne_report1

USE IN tmpReport
SELECT pvoperaruanne_report1
