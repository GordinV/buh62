Parameter cWhere

*!*	CREATE CURSOR eelarve_report2 (idx int, allikas c(20), artikkel c(20), tegev c(20), ;
*!*		eelarve_kinni n(14,2), eelarve_parandatud n(14,2), eelarve_kassa_kinni n(14,2),;
*!*		eelarve_kassa_parandatud n(14,2), tegelik n(14,2), kassa n(14,2),;
*!*		regkood c(20), asutus  c(254), parasutus c(254) null, parregkood c(20) null )

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(rahavoog,'') like '<<ALLTRIM(fltrAruanne.kood3)>>%'
	and idx >= 200
ENDTEXT

If Empty(fltrAruanne.kond)
TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
ENDTEXT
Endif
l_aasta = Year(fltrAruanne.kpv2)


lError = oDb.readFromModel('aruanned\eelarve\taitmine_allikas_artikkel', 'kulud_report', 'l_aasta,fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select idx, regkood, asutus ,;
	parasutus, parregkood, ;
	allikas, tegev, ;
	LEFT(Iif(Left(artikkel,2) = '55',  Left(artikkel,2), (Iif(artikkel = '15,2586,4,5,6', artikkel, Left(artikkel,3)))),20) As artikkel, ;
	(eelarve_kinni) As eelarve_kinni, ;
	(eelarve_parandatud) As eelarve_parandatud, ;
	(eelarve_kassa_kinni) As eelarve_kassa_kinni, ;
	(eelarve_kassa_parandatud) As eelarve_kassa_parandatud, ;
	(tegelik) As tegelik, ;
	(kassa) As kassa ;
From tmpReport ;
	INTO Cursor qryReport

Select allikas, tegev, ;
	artikkel,;
	IIF(Isnull(a.nimetus),'', a.nimetus) As nimetus,;
	sum(eelarve_kinni) As eelarve_kinni, ;
	sum(eelarve_parandatud) As eelarve_parandatud, ;
	sum(eelarve_kassa_kinni) As eelarve_kassa_kinni, ;
	sum(eelarve_kassa_parandatud) As eelarve_kassa_parandatud, ;
	sum(tegelik) As tegelik, ;
	sum(kassa) As kassa, ;
	regkood, asutus ,;
	parasutus, parregkood ;
	from qryReport;
	LEFT Outer Join comEelarveremote a On Left(a.kood,20) = Left(qryReport.artikkel,20) ;
	GROUP By allikas, tegev, idx, artikkel,a.nimetus, regkood, asutus, parasutus,parregkood;
	ORDER By parasutus,asutus, idx, artikkel, allikas, tegev ;
	INTO Cursor eelarve_report2


Use In tmpReport
Use In qryReport
Select eelarve_report2

