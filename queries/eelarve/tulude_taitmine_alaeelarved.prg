Parameter cWhere


TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(rahavoog,'') like '<<ALLTRIM(fltrAruanne.kood3)>>%'
	and artikkel not like '3%'
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF
l_aasta = year(fltrAruanne.kpv2)


lError = oDb.readFromModel('aruanned\eelarve\tulud_allikas_artikkel', 'tulud_report', 'l_aasta,fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve tulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select idx, allikas, tegev, ;
	IIF(LEFT(artikkel,2) = '55',  LEFT(artikkel,2), (IIF(artikkel = '15,2586,4,5,6', artikkel, LEFT(ARTIKKEL,3)))) as artikkel, ;
	(eelarve_kinni) As eelarve_kinni, ;	
	(eelarve_parandatud) As eelarve_parandatud, ;	
	(eelarve_kassa_kinni) As eelarve_kassa_kinni, ;	
	(eelarve_kassa_parandatud) As eelarve_kassa_parandatud, ;	
	(tegelik) as tegelik, ;
	(kassa) As kassa, ;
	regkood, asutus ,;
	parasutus, parregkood ;
	from tmpReport ;
	INTO Cursor qryReport

Select allikas, tegev, ;
	artikkel,; 
	IIF(ISNULL(a.nimetus),'', a.nimetus) as nimetus,;
	sum(eelarve_kinni) As eelarve_kinni, ;	
	sum(eelarve_parandatud) As eelarve_parandatud, ;	
	sum(eelarve_kassa_kinni) As eelarve_kassa_kinni, ;	
	sum(eelarve_kassa_parandatud) As eelarve_kassa_parandatud, ;	
	sum(tegelik) as tegelik, ;
	sum(kassa) As kassa, ;
	regkood, asutus ,;
	parasutus, parregkood ;
	from qryReport;
	LEFT OUTER JOIN comEelarveremote a ON LEFT(a.kood,20) = LEFT(qryReport.artikkel,20) ;
	GROUP By allikas, tegev, idx, artikkel,a.nimetus, regkood, asutus, parasutus,parregkood;
	ORDER By parasutus,asutus, idx, artikkel, allikas, tegev ;
	INTO Cursor eelarve_report2


Use In tmpReport
USE IN qryReport
Select eelarve_report2

