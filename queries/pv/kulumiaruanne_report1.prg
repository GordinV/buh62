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

lError = oDb.readFromModel('aruanned\pv\kulumiaruanne', 'kulumiaruanne_report', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Kulumiaruanne')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT kood, nimetus, konto, grupp, soetmaks, soet_kpv as soetkpv, kulum, alg_kulum as algkulum,kulum + alg_kulum as kulumkokku,; 
	jaak, mahakantud, parandus ;
from tmpReport ;
ORDER BY grupp, kood;
INTO CURSOR kulumiaruanne_report1

USE IN tmpReport
SELECT kulumiaruanne_report1
