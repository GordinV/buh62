Parameter tcWhere

l_where = ''

TEXT TO l_where TEXTMERGE NOSHOW 
	isik_id >= <<IIF(!EMPTY(fltrAruanne.asutusId),fltrAruanne.asutusId, 0)>>
	and isik_id <= <<IIF(!EMPTY(fltrAruanne.asutusId),fltrAruanne.asutusId, 999999999)>>
ENDTEXT

lError = oDb.readFromModel('aruanned\palk\pedagoogide_palk', 'pedagoogide_palk', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv,fltrAruanne.kond,null', 'pedagoogide_palk', l_where)
If !lError
	Messagebox('Viga',0+16, 'Arv. palgaleht')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT pedagoogide_palk