Parameter cWhere


TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(tunnus,'') like '<<ALLTRIM(fltrAruanne.tunnus)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv2)

TEXT TO lcJson TEXTMERGE noshow
		{"artikkel": "<<ALLTRIM(fltrAruanne.kood5)>>",
		"tegev": "<<ALLTRIM(fltrAruanne.kood1)>>",
		"allikas": "<<ALLTRIM(fltrAruanne.kood2)>>",
		"rahavoog": "<<ALLTRIM(fltrAruanne.kood3)>>",
		"tunnus": "<<ALLTRIM(fltrAruanne.tunnus)>>",
		"proj": "<<ALLTRIM(fltrAruanne.proj)>>",
		"objekt": "<<ALLTRIM(fltrAruanne.objekt)>>",
		"taotlus_statusid": <<fltrAruanne.taotlus_statusid>>,
		"uritus": "<<ALLTRIM(fltrAruanne.uritus)>>"}
ENDTEXT


lError = oDb.readFromModel('aruanned\eelarve\taitmine_jaak', 'taitmine_jaak', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond, lcJson', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve täitmine')
	Set Step On
	Select 0
	Return .F.
ENDIF

Select allikas, tegev, artikkel, nimetus, tunnus, ;
	sum(eelarve) as eelarve, sum(eelarve_kassa) as eelarve_kassa, sum(taitmine) as taitmine, sum(taitmine_kassa) as taitmine_kassa,;
	asutus ;
	from tmpReport ;
	GROUP By rekv_id , asutus, allikas, tegev, artikkel, nimetus, tunnus;
	ORDER By rekv_id desc, artikkel, allikas, tegev, tunnus;
	INTO Cursor eelarve_report1

Use In tmpReport
Select eelarve_report1

