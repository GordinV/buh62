Parameter cWhere

* KULUD tegevusalade järgi


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
l_kond = EMPTY(fltrAruanne.tunn)


lError = oDb.readFromModel('aruanned\eelarve\kulud_allikad', 'kulud_report', 'l_aasta,l_kpv,l_kond, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select r.tegev, r.tegev_nimetus, Sum(r.eelarve) As eelarve, Sum(Iif(Empty(fltrAruanne.kassakulud), r.tegelik, r.kassa)) As taitmine,;
	r.regkood, r.asutus , ;
	r.parasutus, r.parregkood ;
	from tmpReport r;
	GROUP By r.tegev, r.tegev_nimetus, r.regkood, r.asutus, r.parasutus,r.parregkood ;
	ORDER By r.parasutus, r.asutus,  r.tegev;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2

