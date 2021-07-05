Parameter cWhere


TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(rahavoog,'') like '<<ALLTRIM(fltrAruanne.kood3)>>%'
	and coalesce(tunnus,'') ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv2)

lError = oDb.readFromModel('aruanned\eelarve\tulud_allikas_artikkel', 'tulud_report', 'l_aasta,fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve tulud')
	Set Step On
	Select 0
	Return .F.
ENDIF

Select allikas, tegev, artikkel, rahavoog, nimetus, tunnus,;
	Sum(eelarve_kinni) As eelarve_kinni, ;	
	Sum(eelarve_parandatud) As eelarve_parandatud, ;	
	Sum(eelarve_kassa_kinni) As eelarve_kassa_kinni, ;	
	Sum(eelarve_kassa_parandatud) As eelarve_kassa_parandatud, ;	
	sum(tegelik) as tegelik, ;
	sum(kassa) As kassa, ;
	regkood, asutus ,;
	parasutus, parregkood ;
	from tmpReport ;
	GROUP By allikas, tegev, idx, artikkel, rahavoog, tunnus, nimetus, regkood, asutus, parasutus,parregkood;
	ORDER By parasutus,asutus, idx, artikkel, allikas, tegev, rahavoog, tunnus ;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2

