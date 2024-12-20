Parameter cWhere


* KULUD asutuste j�rgi

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


lError = oDb.readFromModel('aruanned\eelarve\kulud_allikad', 'kulud_report', 'l_aasta,fltrAruanne.kpv1, fltrAruanne.kpv2, is_parandus, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
Endif

DIMENSION a_arts(11)
a_arts[1] = '21'
a_arts[2] = '22'
a_arts[3] = '23'
a_arts[4] = '24'
a_arts[5] = '25'
a_arts[6] = '26'
a_arts[7] = '27'
a_arts[7] = '28'
a_arts[7] = '29'
a_arts[7] = '34'

	
Select ;
	IIF(LEFT(r.artikkel,2) = '21', r.eelarve, 0) as a21,;
	IIF(LEFT(r.artikkel,2) = '22', r.eelarve, 0) as a22,;
	IIF(LEFT(r.artikkel,2) = '23', r.eelarve, 0) as a23,;
	IIF(LEFT(r.artikkel,2) = '24', r.eelarve, 0) as a24,;
	IIF(LEFT(r.artikkel,2) = '25', r.eelarve, 0) as a25,;
	IIF(LEFT(r.artikkel,2) = '26', r.eelarve, 0) as a26,;
	IIF(LEFT(r.artikkel,2) = '27', r.eelarve, 0) as a27,;
	IIF(LEFT(r.artikkel,2) = '28', r.eelarve, 0) as a28,;
	IIF(LEFT(r.artikkel,2) = '29', r.eelarve, 0) as a29,;
	IIF(LEFT(r.artikkel,2) = '34', r.eelarve, 0) as a34,;
	IIF(ASCAN(a_arts,LEFT(r.artikkel,2)) = 0, r.eelarve, 0) as muud ,;
	r.eelarve as kokku, ;
	r.regkood, r.asutus , ;
	r.parasutus, r.parregkood ;
	from tmpReport r;
	INTO Cursor qry
	
SELECT sum(kokku) as kokku, sum(a21) as a21, sum(a22) as a22, sum(a23) as a23, sum(a24) as a24,;
	sum(a25) as a25, sum(a26) as a26, sum(a27) as a27, sum(a28) as a28, sum(a29) as a29, sum(a34) as a34, sum(muud) as muud, ;
	regkood, asutus, parasutus, parregkood ;
FROM qry ;
GROUP BY regkood, asutus, parasutus, parregkood ;
ORDER BY parregkood, regkood ;
INTO CURSOR eelarve_report3;

Use In tmpReport
Use In qry

Select eelarve_report3

