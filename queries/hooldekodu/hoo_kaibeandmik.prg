Parameter cWhere

TEXT TO lcWhere TEXTMERGE noshow
	(isik_id = <<fltrAruanne.Isikid>> or <<fltrAruanne.Isikid>> = 0)
ENDTEXT

lError = oDb.readFromModel('aruanned\hooldekodu\hoo_kaibeandmik', 'hoo_kaibeandmik', 'gRekv, gUserId,fltrAruanne.kpv1,fltrAruanne.kpv2, fltrAruanne.kond', 'hoo_kaibed', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Hooldekodu')
	Set Step On
	Select 0
	Return .F.
ENDIF

SELECT hoo_kaibed