Parameter tcWhere
l_where = ''

TEXT TO l_where TEXTMERGE NOSHOW 
	isik_id >= <<IIF(!EMPTY(fltrAruanne.asutusId),fltrAruanne.asutusId, 0)>>
	and isik_id <= <<IIF(!EMPTY(fltrAruanne.asutusId),fltrAruanne.asutusId, 999999999)>>
ENDTEXT
l_kond = IIF(EMPTY(fltrAruanne.kond),1 , 0)
 
lError = oDb.readFromModel('aruanned\palk\palk_kokku', 'palk_kokku', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv,l_kond', 'tmpReport', l_where)
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT sum(summa) as summa, nimetus, liik ;
from tmpReport ;
GROUP BY nimetus, liik ;
ORDER BY liik, nimetus ;
INTO CURSOR palksvod_report1 

USE IN tmpReport 

select palksvod_report1
