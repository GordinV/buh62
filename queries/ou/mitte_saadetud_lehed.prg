Parameter cWhere
* Mitte saadetud tootajale palgaleht

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or id = <<fltrAruanne.asutusid>>)
ENDTEXT


lError = oDb.readFromModel('aruanned\ou\mitte_saadetud_lehed', 'saadetud_palk_leht', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'logid_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Logid')
	Set Step On
	Select 0
	Return .F.
Endif

Select logid_report1
