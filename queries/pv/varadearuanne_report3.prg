Parameter cWhere
Local lnDeebet, lnKreedit

* PV inventuuriaruanne 

 
TEXT TO lcWhere TEXTMERGE noshow
	konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT

IF !EMPTY(fltrAruanne.grupp)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and gruppid = <<fltrAruanne.grupp>>
	ENDTEXT
ENDIF

IF !EMPTY(fltrAruanne.aadress)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and aadress is not null and aadress ilike '%<<ALLTRIM(fltrAruanne.aadress)>>%'
	ENDTEXT
ENDIF

IF !EMPTY(fltrAruanne.asutusid)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and vastisikid = <<fltrAruanne.asutusid>>
	ENDTEXT
ENDIF


lError = oDb.readFromModel('aruanned\pv\pv_inventuur', 'pv_inventuur_report', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Varadearuanne')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT id, kood, nimetus, konto, grupp, soetmaks, soetkpv as soetkpv, arv_kulum, kulum, eluiga,; 
	(soetmaks - arv_kulum ) as jaak, mahakantud, vastisik, rentnik, aadress, asutus, SPACE(10) as tegelik, SPACE(10) as puudujaak, SPACE(10) as ulejaak ;
from tmpReport ;
ORDER BY grupp, konto, kood;
INTO CURSOR varadearuanne_report1

USE IN tmpReport
SELECT varadearuanne_report1

