Parameter cWhere
* Eelarve (kassa ja tegelik kulud)    

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and tunnus ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
	and artikkel like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and tegev like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and allikas like '<<ALLTRIM(fltrAruanne.kood2)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv1)
is_parandus = !EMPTY(fltrAruanne.tunn)


lError = oDb.readFromModel('aruanned\eelarve\kulud_allikad', 'kulud_report', 'l_aasta,fltrAruanne.kpv1, fltrAruanne.kpv2, is_parandus, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select r.artikkel, r.tegev, r.nimetus, ;
	Sum(r.eelarve) As eelarve, Sum(r.tegelik) as taitmine_tegelik, sum(r.kassa) As taitmine_kassa,;
	r.regkood, r.asutus , ;
	r.parasutus, r.parregkood ;
	from tmpReport r;
	GROUP By r.artikkel, r.tegev, r.nimetus, r.regkood, r.asutus, r.parasutus,r.parregkood ;
	ORDER By r.parasutus, r.asutus,  r.tegev, r.artikkel ;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2

