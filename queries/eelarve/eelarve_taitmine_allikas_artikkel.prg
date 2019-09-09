Parameter cWhere


TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(tunnus,'') ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(rahavoog,'') like '<<ALLTRIM(fltrAruanne.kood3)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv1)


lError = oDb.readFromModel('aruanned\eelarve\taitmine_allikas_artikkel', 'kulud_report', 'l_aasta,fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select allikas, tegev, artikkel, rahavoog, nimetus, tunnus,;
	Sum(eelarve_kinni) As eelarve_kinni, ;	
	Sum(eelarve_parandatud) As eelarve_parandatud, ;	
	sum(tegelik) as tegelik, sum(tegelik_kbm) as tegelik_kbm,;
	sum(kassa) As kassa, sum(kassa_kbm) As kassa_kbm,;
	regkood, asutus ,;
	parasutus, parregkood ;
	from tmpReport ;
	GROUP By allikas, tegev, artikkel,rahavoog, nimetus, regkood, asutus, parasutus,parregkood, tunnus ;
	ORDER By parasutus,asutus, allikas, tegev, artikkel, rahavoog, tunnus ;
	INTO Cursor eelarve_report2

Use In tmpReport
Select eelarve_report2

