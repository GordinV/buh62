Parameter cWhere

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(tunnus,'') ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv1)
l_kpv = fltrAruanne.kpv2
is_parandus = !EMPTY(fltrAruanne.tunn)


lError = oDb.readFromModel('aruanned\eelarve\tulud_allikad', 'tulud_report', 'l_aasta,fltrAruanne.kpv1, fltrAruanne.kpv2, is_parandus, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve tulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select artikkel, nimetus, Sum(eelarve) As eelarve, Sum(Iif(Empty(fltrAruanne.kassakulud), tegelik, kassa)) As taitmine,;
	regkood, asutus ,;
	parasutus, parregkood ;
	from tmpReport ;
	GROUP By artikkel, nimetus, regkood, asutus, parasutus, parregkood ;
	ORDER By parasutus,asutus,  artikkel ;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2

