Parameter cWhere


TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
ENDTEXT


TEXT TO lcJson TEXTMERGE noshow
		{"artikkel": "<<ALLTRIM(fltrAruanne.kood5)>>",
		"tegev": "<<ALLTRIM(fltrAruanne.kood1)>>",
		"allikas": "<<ALLTRIM(fltrAruanne.kood2)>>",
		"rahavoog": "<<ALLTRIM(fltrAruanne.kood3)>>",
		"tunnus": "<<ALLTRIM(fltrAruanne.tunnus)>>",
		"proj": "<<ALLTRIM(fltrAruanne.proj)>>",
		"objekt": "<<ALLTRIM(fltrAruanne.objekt)>>",
		"uritus": "<<ALLTRIM(fltrAruanne.uritus)>>"}		
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv2)


lError = oDb.readFromModel('aruanned\eelarve\eelarve_taitmine_art_ta_allikas_proj_tunnus', 'eelarve_taitmine_report', 'l_aasta,fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv, fltrAruanne.kond,lcJson', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
ENDIF

Select rekv_id,;
	Sum(eelarve_kinni) As eelarve_kinni_kokku, ;	
	Sum(eelarve_parandatud) As eelarve_parandatud_kokku, ;	
	Sum(eelarve_kassa_kinni) As eelarve_kassa_kinni_kokku, ;	
	Sum(eelarve_kassa_parandatud) As eelarve_kassa_parandatud_kokku, ;	
	sum(tegelik) as tegelik_kokku, ;
	sum(kassa) As kassa_kokku ;
	from tmpReport ;
	WHERE artikkel NOT in ('2585(A80)','2586(A80)', '1,2,3,6', '3', '15, 3, 655','15,2586,4,5,6');
	group by rekv_id;
	INTO Cursor report_kokku
* 15,2586,4,5,6


Select allikas, tegev, artikkel, tunnus, proj, uritus,objekt,;
	Sum(eelarve_kinni) As eelarve_kinni, ;	
	Sum(eelarve_parandatud) As eelarve_parandatud, ;	
	Sum(eelarve_kassa_kinni) As eelarve_kassa_kinni, ;	
	Sum(eelarve_kassa_parandatud) As eelarve_kassa_parandatud, ;	
	sum(tegelik) as tegelik, ;
	sum(kassa) As kassa, ;
	regkood, asutus ,;
	parasutus, parregkood, ;
	sum(report_kokku.eelarve_kinni_kokku) as eelarve_kinni_kokku,;
	sum(report_kokku.eelarve_parandatud_kokku) as eelarve_parandatud_kokku,;
	sum(report_kokku.eelarve_kassa_kinni_kokku) as eelarve_kassa_kinni_kokku,;
	sum(report_kokku.eelarve_kassa_parandatud_kokku) as eelarve_kassa_parandatud_kokku,;
	sum(report_kokku.tegelik_kokku) as tegelik_kokku,;
	sum(report_kokku.kassa_kokku) as kassa_kokku,;
	report_kokku.rekv_id;
	from tmpReport,  report_kokku;
	WHERE tmpReport.rekv_id = report_kokku.rekv_id;
	GROUP By allikas, tegev, idx, artikkel, tunnus, proj, uritus, objekt, regkood, asutus, parasutus,parregkood,report_kokku.rekv_id;
	ORDER By parasutus,asutus, idx, artikkel, allikas, tegev, tunnus,proj, uritus ;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2

