Parameter tcWhere

l_where = ''

TEXT TO l_where TEXTMERGE NOSHOW 
	isik_id >= <<IIF(!EMPTY(fltrAruanne.asutusId),fltrAruanne.asutusId, 0)>>
	and isik_id <= <<IIF(!EMPTY(fltrAruanne.asutusId),fltrAruanne.asutusId, 999999999)>>
ENDTEXT

lError = oDb.readFromModel('aruanned\palk\palk_leht', 'palk_leht', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv,fltrAruanne.kond', 'tmpReport', l_where)
If !lError
	Messagebox('Viga',0+16, 'Arv. palgaleht')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT * ;
from tmpReport ;
ORDER BY isik, nimetus ;
INTO CURSOR arvleht_report1 

USE IN tmpReport

SELECT arvleht_report1