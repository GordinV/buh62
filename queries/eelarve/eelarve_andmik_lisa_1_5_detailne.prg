Lparameters tcParams

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekvid = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegevus,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(tunnus,'') like '<<ALLTRIM(fltrAruanne.tunnus)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekvid = <<gRekv>>
ENDTEXT
Endif

Wait Window 'Päring...' Nowait
lError = oDb.readFromModel('aruanned\eelarve\eelarve_andmik_lisa_1_5_detailne', 'eelarve_andmik_lisa_1_5_report', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'eelarve_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve täitmine')
	Set Step On
	Select 0
	Return .F.
Endif

Wait Window 'Andmed, analüüs...' Nowait


Select eelarve_report1
