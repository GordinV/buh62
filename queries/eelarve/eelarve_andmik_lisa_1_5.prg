Lparameters tcParams
*!*		SET STEP on
*!*	gRekv = 64
*!*	CREATE CURSOR fltrAruanne (kpv2 d, kond i)
*!*	APPEND BLANK
*!*	replace kpv2 WITH DATE(2019,01,03), kond WITH 0
*!*
*!*	gnHandle = SQLCONNECT('NarvaLvPg','vlad','Vlad490710')
*!*

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekvid = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
ENDTEXT

If Empty(fltrAruanne.kond)
TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekvid = <<gRekv>>
ENDTEXT
Endif

Wait Window 'Päring...' Nowait
lError = oDb.readFromModel('aruanned\eelarve\eelarve_andmik_lisa_1_5', 'eelarve_andmik_lisa_1_5_report', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'qryReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve täitmine')
	Set Step On
	Select 0
	Return .F.
Endif



Wait Window 'Andmed, analüüs...' Nowait

Create Cursor eelarve_report_query (idx c(20), sub_idx Integer Default 0, idx1 Integer Default 5, is_esita c(1) Null, rekvid i, tegev c(20), artikkel c(20), nimetus c(254) Null,;
	eelarve N(14,2) Null , eelarve_kassa N(14,2) Null, eelarve_taps N(14,2) Null, eelarve_kassa_taps N(14,2) Null,;
	tegelik N(14,2) Null, kassa N(14,2) Null, saldoandmik N(14,2) Null)


* kontrol
Create Cursor kontrol_report (rea_1 c(254), rea_2 c(254), rea_3 c(254), rea_4 c(254), rea_5 c(254), rea_6 c(254), rea_7 c(254),rea_8 c(254),;
	rea_9 c(254), rea_10 c(254),rea_11 c(254),rea_12 c(254),rea_13 c(254),rea_14 c(254),rea_15 c(254),;
	summa_11 N(14,2), summa_12 N(14,2), summa_13 N(14,2),summa_14 N(14,2),summa_15 N(14,2),summa_16 N(14,2),;
	summa_21 N(14,2), summa_22 N(14,2),summa_23 N(14,2),summa_24 N(14,2),summa_25 N(14,2),summa_26 N(14,2),;
	summa_31 N(14,2), summa_32 N(14,2), summa_33 N(14,2), summa_34 N(14,2),summa_35 N(14,2),summa_36 N(14,2),;
	summa_41 N(14,2), summa_42 N(14,2), summa_43 N(14,2),summa_44 N(14,2),summa_45 N(14,2),summa_46 N(14,2),;
	summa_51 c(20), summa_52 c(20), summa_53 c(20), summa_54 c(20), summa_55 c(20), summa_56 c(20))


* 3000+3030+3044+3045+3047

Select 'S' As is_esita, ;
	'2.1' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '30' As artikkel, Upper('Maksutulud') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa,;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, Sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Left(artikkel,4) In ('3000','3030','3044','3045','3047') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

*	where artikkel in  ('3500','352','35200','35201') ;

Select 'S' As is_esita, ;
	'2.1' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '35' As artikkel, Upper('Saadud toetused tegevuskuludeks') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps,;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Left(artikkel,2) Like  '35%' ;
	AND artikkel Not In ('3502');
	INTO Cursor tmp1

*	AND artikkel NOT in ('3502','352');	update 02.04.2021 V.B


Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

Select 'S' As is_esita, ;
	'2.1' As idx, 3 As sub_idx, gRekv As rekvid, Space(20) As tegev, '38' As artikkel, Upper('Muud tegevustulud ') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where (artikkel  In ('3818') Or Left(artikkel,3) In ('388','382'));
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1


Select 'S' As is_esita, ;
	'2.11' As idx, 4 As sub_idx, gRekv As rekvid, Space(20) As tegev, '4' As artikkel, Upper('Antud toetused tegevuskuludeks') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where (artikkel Like '40%' Or artikkel Like '413%' Or artikkel Like '4500%'  Or artikkel Like '452%');
	INTO Cursor tmp1
*40+413+4500+452

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

Select 'S' As is_esita, ;
	'2.12' As idx, 4 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Muud tegevuskulud') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where (artikkel Like '5%' Or Left(artikkel,2) = '60') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')
Use In tmp1


Select Iif(Empty(q.is_e),'E','') As is_esita,  ;
	q.idx, 8 As sub_idx, q.rekvid, q.tegev, q.artikkel, q.nimetus, ;
	q.eelarve, q.eelarve_kassa, ;
	q.eelarve_taps, q.eelarve_kassa_taps, ;
	q.tegelik, q.kassa, q.saldoandmik ;
	from qryReport q ;
	INTO Cursor tmp2


Select eelarve_report_query

Append From Dbf('tmp2')

Use In tmp2



*  30+32+35+38
Select 'S' As is_esita, ;
	'1.0' As idx, 0 As sub_idx, gRekv As rekvid, Space(20) As tegev, Space(20) As artikkel, Upper('PÕHITEGEVUSE TULUD KOKKU') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM eelarve_report_query ;
	where artikkel In ('30','32', '35','38') ;
	INTO Cursor tmp_tulud_kokku

Select eelarve_report_query
Append From Dbf('tmp_tulud_kokku')


Select 'S' As is_esita, ;
	'2.11' As idx, 4 As idx1, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('PÕHITEGEVUSE KULUD KOKKU') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where (Left(artikkel,2) In ('60') Or artikkel Like '4%' Or artikkel Like '5%') ;
	AND artikkel Not In ('4502');
	INTO Cursor tmp_kulud_kokku

Select eelarve_report_query
Append From Dbf('tmp_kulud_kokku')


Insert Into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , eelarve_kassa, eelarve_taps, eelarve_kassa_taps, tegelik , kassa, saldoandmik ) ;
	VALUES ('2.3', 2, 'S', gRekv , Space(20), '', Upper('PÕHITEGEVUSE TULEM') , ;
	(tmp_tulud_kokku.eelarve + tmp_kulud_kokku.eelarve),;
	(tmp_tulud_kokku.eelarve_kassa + tmp_kulud_kokku.eelarve_kassa),;
	(tmp_tulud_kokku.eelarve_taps + tmp_kulud_kokku.eelarve_taps),;
	(tmp_tulud_kokku.eelarve_kassa_taps + tmp_kulud_kokku.eelarve_kassa_taps),;
	(tmp_tulud_kokku.tegelik + tmp_kulud_kokku.tegelik) , ;
	(tmp_tulud_kokku.kassa + tmp_kulud_kokku.kassa), ;
	(tmp_tulud_kokku.saldoandmik + tmp_kulud_kokku.saldoandmik) )


Select 'S' As is_esita, ;
	'2.4' As idx, 1 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('INVESTEERIMISTEGEVUS KOKKU') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(artikkel) In ('381', '15','3502','4502','1502','1501','1512','1511','1531', '1532', '1032','655','650') ;
	INTO Cursor investeerimis_tegevus

Select eelarve_report_query
Append From Dbf('investeerimis_tegevus')

Insert Into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , eelarve_kassa, ;
	eelarve_taps, eelarve_kassa_taps,;
	tegelik , kassa, saldoandmik ) ;
	VALUES ('2.4.6', 1, 'S', gRekv , Space(20), '', Upper('EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))') , ;
	(tmp_tulud_kokku.eelarve + tmp_kulud_kokku.eelarve) + investeerimis_tegevus.eelarve,;
	(tmp_tulud_kokku.eelarve_kassa + tmp_kulud_kokku.eelarve_kassa) + investeerimis_tegevus.eelarve_kassa,;
	(tmp_tulud_kokku.eelarve_taps + tmp_kulud_kokku.eelarve_taps) + investeerimis_tegevus.eelarve_taps,;
	(tmp_tulud_kokku.eelarve_kassa_taps + tmp_kulud_kokku.eelarve_kassa_taps) + investeerimis_tegevus.eelarve_kassa_taps,;
	(tmp_tulud_kokku.tegelik + tmp_kulud_kokku.tegelik) + investeerimis_tegevus.tegelik , ;
	(tmp_tulud_kokku.kassa + tmp_kulud_kokku.kassa) + investeerimis_tegevus.kassa, ;
	(tmp_tulud_kokku.saldoandmik + tmp_kulud_kokku.saldoandmik) + investeerimis_tegevus.saldoandmik )


Select 'S' As is_esita, ;
	'2.4.6' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('FINANTSEERIMISTEGEVUS') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Left(artikkel,4) In ('2585','2586') ;
	INTO Cursor finants_tegenus

Select eelarve_report_query
Append From Dbf('finants_tegenus')


Select 'S' As is_esita, ;
	'2.4.8' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('NÕUETE JA KOHUSTUSTE SALDODE MUUTUS (tekkepõhise e/a korral) (+/-)') As nimetus, ;
	qryReport.eelarve - ((tmp_tulud_kokku.eelarve + tmp_kulud_kokku.eelarve) + investeerimis_tegevus.eelarve) - finants_tegenus.eelarve As eelarve, ;
	qryReport.eelarve_kassa - ((tmp_tulud_kokku.eelarve_kassa + tmp_kulud_kokku.eelarve_kassa) + investeerimis_tegevus.eelarve_kassa) - finants_tegenus.eelarve_kassa As eelarve_kassa, ;
	qryReport.eelarve_taps - ((tmp_tulud_kokku.eelarve_taps + tmp_kulud_kokku.eelarve_taps) + investeerimis_tegevus.eelarve_taps) - ;
	finants_tegenus.eelarve_taps As eelarve_taps, ;
	qryReport.eelarve_kassa_taps - ((tmp_tulud_kokku.eelarve_kassa_taps + tmp_kulud_kokku.eelarve_kassa_taps) + ;
	investeerimis_tegevus.eelarve_kassa_taps) - finants_tegenus.eelarve_kassa_taps As eelarve_kassa_taps, ;
	qryReport.tegelik - ((tmp_tulud_kokku.tegelik + tmp_kulud_kokku.tegelik) + investeerimis_tegevus.tegelik) - finants_tegenus.tegelik As tegelik, ;
	0  As kassa, ;
	qryReport.saldoandmik - ((tmp_tulud_kokku.saldoandmik + tmp_kulud_kokku.saldoandmik) + investeerimis_tegevus.saldoandmik) - finants_tegenus.saldoandmik  As saldoandmik ;
	FROM qryReport;
	where Alltrim(artikkel) = ('100') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

*-- PÕHITEGEVUSE KULUDE JA INVESTEERIMISTEGEVUSE VÄLJAMINEKUTE JAOTUS TEGEVUSALADE JÄRGI


Select 'S' As is_esita, ;
	'3.1' As idx, 0 As sub_idx, gRekv As rekvid,;
	'' As tegev, '' As artikkel, Upper('Põhitegevuse kulude ja investeerimistegevuse väljaminekute jaotus tegevusalade järgi') As nimetus,;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport;
	where !Empty(tegev);
	INTO Cursor tegev_kokku

Select eelarve_report_query
Append From Dbf('tegev_kokku')

Use In tegev_kokku


* Üldised valitsussektori teenused


Select 'S' As is_esita, ;
	'3.1' As idx, 1 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Üldised valitsussektori teenused') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps,;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('01111', '01112','01114','01600','01700',;
	'01110','01120','01130','01210','01220','01310','01320','01330','01400','01500','01800') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* 	IIF(ISNULL(q.eelarve),00000000.00,q.eelarve) as eelarve, q.tegelik, q.kassa, q.saldoandmik ;

* Ülalnimetamata üldised valitsussektori kulud kokku

Update eelarve_report_query  ;
	SET idx = '3.1.0', sub_idx = 4 ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In  ('01110','01120','01130','01210','01220','01310','01320','01330','01400','01500','01800')

Select 'S' As is_esita, ;
	'3.1.0' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Ülalnimetamata üldised valitsussektori kulud kokku') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('01110','01120','01130','01210','01220','01310','01320','01330','01400','01500','01800') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Riigikaitse


Update eelarve_report_query  ;
	SET idx = '3.1.1', sub_idx = 4, is_esita = 'E' ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In  ('02100','02200','02300','02400','02500')

Select 'S' As is_esita, ;
	'3.1.1' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Riigikaitse') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('02100','02200','02300','02400','02500') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Avalik kord ja julgeolek

Update eelarve_report_query  ;
	SET idx = '3.1.2', sub_idx = 4 ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In  ('03100','03200')

Select 'S' As is_esita, ;
	'3.1.2' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Avalik kord ja julgeolek') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('03100','03200')  ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Muu avalik kord ja julgeolek kokku

Update eelarve_report_query  ;
	SET idx = '3.1.2', ;
	sub_idx = 4, ;
	is_esita = 'E' ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In  ('03101','03300','03400','03500','03600')

* ,'03600'

Select 'S' As is_esita, ;
	'3.1.2' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Muu avalik kord ja julgeolek kokku') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('03101','03300','03400','03500','03600')   ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Majandus


Update eelarve_report_query  ;
	SET idx = '3.1.3', ;
	sub_idx = 4 ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In  ('04120','04210','04220','04230','04350','04360','04510','04512','04520', '04540','04600','04710','04730','04740','04900')

Select 'S' As is_esita, ;
	'3.1.3' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Majandus') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('04120','04210','04220','04230','04350','04360','04510','04512','04520', '04540','04600','04710','04730','04740','04900');
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Ülalnimetamata majandus kokku

Update eelarve_report_query  ;
	SET idx = '3.1.4', ;
	sub_idx = 4, ;
	is_esita = 'E' ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870')

Select 'S' As is_esita, ;
	'3.1.4' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Ülalnimetamata majandus kokku') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Keskkonnakaitse

Update eelarve_report_query  ;
	SET idx = '3.1.5', ;
	sub_idx = 4 ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In ('05100','05101','05200','05300','05400')

Select 'S' As is_esita, ;
	'3.1.5' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Keskkonnakaitse') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('05100','05101','05200','05300','05400');
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Muu keskkonnakaitse

Update eelarve_report_query  ;
	SET idx = '3.1.5', ;
	sub_idx = 6, ;
	is_esita = 'E' ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In ('05500','05600')

Select 'S' As is_esita, ;
	'3.1.5' As idx, 5 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Muu keskkonnakaitse') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('05500','05600');
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Elamu- ja kommunaalmajandus

Update eelarve_report_query  ;
	SET idx = '3.1.6', ;
	sub_idx = 4 ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(tegev) In ('06100','06200','06300','06400','06500','06605')

Select 'S' As is_esita, ;
	'3.1.6' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Elamu- ja kommunaalmajandus') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('06100','06200','06300','06400','06500','06605') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Tervishoid

Update eelarve_report_query  ;
	SET idx = '3.1.70', ;
	sub_idx = 2, ;
	is_esita = Iif((Alltrim(tegev) = '07110' Or Alltrim(tegev) = '07400' Or Alltrim(tegev) = '07600'),'','E') ;
	WHERE Alltrim(idx) = '3.1' ;
	AND Alltrim(Left(tegev,2)) =  '07'

* '07310','07340','07210','07220',


Select 'S' As is_esita, ;
	'3.1.7' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Tervishoid') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa,  ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('07110','07210','07220','07230','07240','07310','07320','07330','07340','07400','07600','07120','07130','07500') ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Ülalnimetamata tervishoid kokku

Update eelarve_report_query  ;
	SET idx = '3.1.71', ;
	sub_idx = 4, ;
	is_esita = 'E' ;
	WHERE Alltrim(tegev) In ('07120','07130','07500')

Select 'S' As is_esita, ;
	'3.1.71' As idx, 3 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Ülalnimetamata tervishoid kokku') As nimetus, ;
	sum(eelarve) As eelarve,Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('07120','07130','07500')  ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1


* Vaba aeg, kultuur ja religioon

Create Cursor tmp_tegev (kood c(20))
Insert Into tmp_tegev (kood) Values ('08102')
Insert Into tmp_tegev (kood) Values ('08103')
Insert Into tmp_tegev (kood) Values ('08105')
Insert Into tmp_tegev (kood) Values ('08106')
Insert Into tmp_tegev (kood) Values ('08107')
Insert Into tmp_tegev (kood) Values ('08108')
Insert Into tmp_tegev (kood) Values ('08109')
Insert Into tmp_tegev (kood) Values ('08201')
Insert Into tmp_tegev (kood) Values ('08202')
Insert Into tmp_tegev (kood) Values ('08203')
Insert Into tmp_tegev (kood) Values ('08204')
Insert Into tmp_tegev (kood) Values ('08205')
Insert Into tmp_tegev (kood) Values ('08206')
Insert Into tmp_tegev (kood) Values ('08207')
Insert Into tmp_tegev (kood) Values ('08208')
Insert Into tmp_tegev (kood) Values ('08209')
Insert Into tmp_tegev (kood) Values ('08210')
Insert Into tmp_tegev (kood) Values ('08211')
Insert Into tmp_tegev (kood) Values ('08212')
Insert Into tmp_tegev (kood) Values ('08234')
Insert Into tmp_tegev (kood) Values ('08236')
Insert Into tmp_tegev (kood) Values ('08300')
Insert Into tmp_tegev (kood) Values ('08400')
Insert Into tmp_tegev (kood) Values ('08500')
Insert Into tmp_tegev (kood) Values ('08600')

Update eelarve_report_query  ;
	SET idx = '3.1.8', ;
	sub_idx = 4 ;
	WHERE Alltrim(tegev) In (Select kood From tmp_tegev)


Select 'S' As is_esita, ;
	'3.1.8' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Vaba aeg, kultuur ja religioon') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	WHERE Alltrim(tegev) In (Select kood From tmp_tegev);
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1
Use In tmp_tegev

* Haridus

Update eelarve_report_query  ;
	SET idx = '3.1.9', ;
	sub_idx = 4 ;
	WHERE Alltrim(tegev) In ('09110','09210','09211','09212','09213','09220','09221','09222','09400','09500','09510',;
	'09600','09601','09602','09700','09800')

Select 'S' As is_esita, ;
	'3.1.9' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Haridus') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('09110','09210','09211','09212','09213','09220','09221','09222','09400','09500','09510',;
	'09600','09601','09602','09700','09800')  ;
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1

* Sotsiaalne kaitse


Update eelarve_report_query  ;
	SET idx = '3.1.91', ;
	sub_idx = 4 ;
	WHERE Alltrim(tegev) In ('10110','10120','10121','10200','10201','10300','10400','10402','10500','10600',;
	'10700','10701','10702','10800','10900')

Select 'S' As is_esita, ;
	'3.1.91' As idx, 2 As sub_idx, gRekv As rekvid, Space(20) As tegev, '' As artikkel, Upper('Sotsiaalne kaitse') As nimetus, ;
	sum(eelarve) As eelarve, Sum(eelarve_kassa) As eelarve_kassa, ;
	sum(eelarve_taps) As eelarve_taps, Sum(eelarve_kassa_taps) As eelarve_kassa_taps, ;
	sum(tegelik) As tegelik, Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik ;
	FROM qryReport ;
	where Alltrim(tegev) In ('10110','10120','10121','10200','10201','10300','10400','10402','10500','10600',;
	'10700','10701','10702','10800','10900');
	INTO Cursor tmp1

Select eelarve_report_query
Append From Dbf('tmp1')

Use In tmp1



* gruppid tegevusallad esimised 2 numberid


* kulud tegev. jargi kokku "Põhitegevuse kulude ja investeerimistegevuse väljaminekute jaotus tegevusalade järgi"



* MUUD NÄITAJAD

Insert Into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , eelarve_kassa, eelarve_taps , eelarve_kassa_taps, tegelik , kassa, saldoandmik ) ;
	VALUES ('8.1', 0, 'N', gRekv , Space(20), '', Upper('MUUD NÄITAJAD ') , ;
	0,;
	0, ;
	0,;
	0, ;
	0, ;
	0, ;
	0 )

* Aasta alguse seisuga

Insert Into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , eelarve_kassa, eelarve_taps , eelarve_kassa_taps, tegelik , kassa, saldoandmik ) ;
	VALUES ('8.11', 0, 'N', gRekv , Space(20), '', Upper('Aasta alguse seisuga') , ;
	0,;
	0,;
	0, ;
	0, ;
	0, ;
	0, ;
	0 )


* Perioodi lõpu seisuga

Insert Into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , eelarve_kassa, eelarve_taps , eelarve_kassa_taps, tegelik , kassa, saldoandmik ) ;
	VALUES ('8.2', 1, 'N', gRekv , Space(20), '', Upper('Perioodi lõpu seisuga') , ;
	0,;
	0, ;
	0, 0,;
	0, ;
	0, ;
	0 )


Use In qryReport

*!*		order by idx, tegev, artikkel ;
*!*		INTO CURSOR eelarve_report1


Select kontrol_report
Append Blank

* Kontroll: likviidsed varad
*l_result_kassa =  get_kontrol ('8.10-5-1','','','kassa') + get_kontrol ('','100','','kassa') - get_kontrol ('','1001','','kassa')
*l_result_saldo =  get_kontrol ('8.10-5-1','','','saldoandmik') + get_kontrol ('','100','','saldoandmik') - get_kontrol ('','1001','','saldoandmik')


l_field = 'eelarve_kassa_taps'
l_result_eelarve_kassa_taps =  get_kontrol ('','1000','',l_field) + get_kontrol ('','100','',l_field) - get_kontrol ('','1001','',l_field)

l_field = 'eelarve_kassa'
l_result_eelarve_kassa =  get_kontrol ('','1000','',l_field) + get_kontrol ('','100','',l_field) - get_kontrol ('','1001','',l_field)

l_field = 'eelarve'
l_result_eelarve =  get_kontrol ('','1000','',l_field) + get_kontrol ('','100','',l_field) - get_kontrol ('','1001','',l_field)

l_field = 'eelarve_taps'
l_result_eelarve_taps =  get_kontrol ('','1000','',l_field) + get_kontrol ('','100','',l_field) - get_kontrol ('','1001','',l_field)

l_field = 'kassa'
l_result_kassa =  get_kontrol ('','1000','',l_field) + get_kontrol ('','100','',l_field) - get_kontrol ('','1001','',l_field)

l_field = 'saldoandmik'
l_result_saldo =  get_kontrol ('','1000','',l_field) + get_kontrol ('','100','',l_field) - get_kontrol ('','1001','',l_field)


If !Empty(l_result_kassa) Or  !Empty(l_result_saldo) Or !Empty(l_result_eelarve) Or !Empty(l_result_eelarve_taps) Or ;
		!Empty(l_result_eelarve_kassa_taps ) Or !Empty(l_result_eelarve_kassa )

	Replace rea_1 With 'Kontroll: likviidsed varad', ;
		summa_11 With l_result_kassa,;
		summa_12 With l_result_saldo,;
		summa_13 With l_result_eelarve,;
		summa_14 With l_result_eelarve_taps,;
		summa_16 With l_result_eelarve_kassa_taps ,;
		summa_15 With l_result_eelarve_kassa In kontrol_report
Endif



* majandusliku sisu ja tegevusalade võrdlus
l_field = 'eelarve_kassa_taps'
l_result_eelarve_kassa_taps =  get_kontrol ('2.11-4-2','','',l_field ) + get_kontrol ('','15','',l_field ) + ;
	get_kontrol ('','4502','',l_field ) + ;
	get_kontrol ('','1501','',l_field ) + get_kontrol ('','1511','',l_field ) + get_kontrol ('','1531','',l_field )+;
	get_kontrol ('','650','',l_field ) +	get_kontrol ('3.1-5-0','','',l_field)

l_field = 'eelarve_kassa'

l_result_eelarve_kassa_taps =  get_kontrol ('2.11-4-2','','',l_field ) + get_kontrol ('','15','',l_field ) + ;
	get_kontrol ('','4502','',l_field ) + ;
	get_kontrol ('','1501','',l_field ) + get_kontrol ('','1511','',l_field ) + get_kontrol ('','1531','',l_field )+;
	get_kontrol ('','650','',l_field ) +	get_kontrol ('3.1-5-0','','',l_field)

l_field = 'eelarve'
l_result_eelarve_kassa_taps =  get_kontrol ('2.11-4-2','','',l_field ) + get_kontrol ('','15','',l_field ) + ;
	get_kontrol ('','4502','',l_field ) + ;
	get_kontrol ('','1501','',l_field ) + get_kontrol ('','1511','',l_field ) + get_kontrol ('','1531','',l_field )+;
	get_kontrol ('','650','',l_field ) +	get_kontrol ('3.1-5-0','','',l_field)

l_field = 'eelarve_taps'
l_result_eelarve_kassa_taps =  get_kontrol ('2.11-4-2','','',l_field ) + get_kontrol ('','15','',l_field ) + ;
	get_kontrol ('','4502','',l_field ) + ;
	get_kontrol ('','1501','',l_field ) + get_kontrol ('','1511','',l_field ) + get_kontrol ('','1531','',l_field )+;
	get_kontrol ('','650','',l_field ) +	get_kontrol ('3.1-5-0','','',l_field)

l_field = 'kassa'
l_result_eelarve_kassa_taps =  get_kontrol ('2.11-4-2','','',l_field ) + get_kontrol ('','15','',l_field ) + ;
	get_kontrol ('','4502','',l_field ) + ;
	get_kontrol ('','1501','',l_field ) + get_kontrol ('','1511','',l_field ) + get_kontrol ('','1531','',l_field )+;
	get_kontrol ('','650','',l_field ) +	get_kontrol ('3.1-5-0','','',l_field)

l_field = 'saldoandmik'
l_result_eelarve_kassa_taps =  get_kontrol ('2.11-4-2','','',l_field ) + get_kontrol ('','15','',l_field ) + ;
	get_kontrol ('','4502','',l_field ) + ;
	get_kontrol ('','1501','',l_field ) + get_kontrol ('','1511','',l_field ) + get_kontrol ('','1531','',l_field )+;
	get_kontrol ('','650','',l_field ) +	get_kontrol ('3.1-5-0','','',l_field)

If !Empty(l_result_kassa) Or  !Empty(l_result_saldo) Or !Empty(l_result_eelarve) Or !Empty(l_result_eelarve_taps) Or ;
		!Empty(l_result_eelarve_kassa_taps ) Or !Empty(l_result_eelarve_kassa )

	Replace rea_2 With 'Kontroll: majandusliku sisu ja tegevusalade võrdlus',;
		summa_21 With l_result_kassa,;
		summa_22 With l_result_saldo,;
		summa_23 With l_result_eelarve ,;
		summa_25 With l_result_eelarve_kassa ,;
		summa_26 With l_result_eelarve_kassa_taps,;
		summa_24 With l_result_eelarve_taps In kontrol_report

Endif

* Tasakaalu kontroll
l_field = 'eelarve_kassa_taps'
l_result_eelarve_kassa_taps =  get_kontrol ('2.4.6-5-1','','',l_field) +  get_kontrol ('2.4.6-5-2','','',l_field) - ;
	get_kontrol ('','100','',l_field) + get_kontrol ('2.4.8-5-2','','',l_field)

l_field = 'eelarve_kassa'
l_result_eelarve_kassa =  get_kontrol ('2.4.6-5-1','','',l_field) +  get_kontrol ('2.4.6-5-2','','',l_field) - ;
	get_kontrol ('','100','',l_field) + get_kontrol ('2.4.8-5-2','','',l_field)

l_field = 'eelarve'
l_result_eelarve =  get_kontrol ('2.4.6-5-1','','',l_field) +  get_kontrol ('2.4.6-5-2','','',l_field) - ;
	get_kontrol ('','100','',l_field) + get_kontrol ('2.4.8-5-2','','',l_field)

l_field = 'eelarve_taps'
l_result_eelarve_taps =  get_kontrol ('2.4.6-5-1','','',l_field) +  get_kontrol ('2.4.6-5-2','','',l_field) - ;
	get_kontrol ('','100','',l_field) + get_kontrol ('2.4.8-5-2','','',l_field)

l_field = 'kassa'
l_result_kassa =  get_kontrol ('2.4.6-5-1','','',l_field) +  get_kontrol ('2.4.6-5-2','','',l_field) - ;
	get_kontrol ('','100','',l_field) + get_kontrol ('2.4.8-5-2','','',l_field)

l_field = 'saldoandmik'
l_result_saldo =  get_kontrol ('2.4.6-5-1','','',l_field) +  get_kontrol ('2.4.6-5-2','','',l_field) - ;
	get_kontrol ('','100','',l_field) + get_kontrol ('2.4.8-5-2','','',l_field)

If !Empty(l_result_kassa) Or  !Empty(l_result_saldo) Or !Empty(l_result_eelarve) Or !Empty(l_result_eelarve_taps) Or ;
		!Empty(l_result_eelarve_kassa_taps ) Or !Empty(l_result_eelarve_kassa )

	Replace rea_4 With ' Tasakaalu kontroll', ;
		summa_41 With l_result_kassa, ;
		summa_42 With l_result_saldo,;
		summa_43 With l_result_eelarve , ;
		summa_45 With l_result_eelarve_kassa , ;
		summa_46 With l_result_eelarve_kassa_taps , ;
		summa_44 With l_result_eelarve_taps In kontrol_report
Endif


* Art. 100 ja vaba jäägi võrdlus (read 162 ja 52)

l_field = 'eelarve_kassa_taps'
l_result_eelarve_kassa_taps =  Iif(get_kontrol ('','1000','',l_field ) <  (-1 * get_kontrol ('','100','',l_field )), 'FALSE', 'OK')

l_field = 'eelarve_kassa'
l_result_eelarve_kassa =  Iif(get_kontrol ('','1000','',l_field ) <  (-1 * get_kontrol ('','100','',l_field )), 'FALSE', 'OK')

l_field = 'eelarve'
l_result_eelarve =  Iif(get_kontrol ('','1000','',l_field ) <  (-1 * get_kontrol ('','100','',l_field )), 'FALSE', 'OK')

l_field = 'eelarve_taps'
l_result_eelarve_taps =  Iif(get_kontrol ('','1000','',l_field ) <  (-1 * get_kontrol ('','100','',l_field )), 'FALSE', 'OK')

l_field = 'kassa'
l_result_kassa =  Iif(get_kontrol ('','1000','',l_field ) <  (-1 * get_kontrol ('','100','',l_field )), 'FALSE', 'OK')

l_field = 'saldoandmik'
l_result_saldo =  Iif(get_kontrol ('','1000','',l_field ) <  (-1 * get_kontrol ('','100','',l_field )), 'FALSE', 'OK')

If !Empty(l_result_kassa) Or  !Empty(l_result_saldo) Or !Empty(l_result_eelarve) Or !Empty(l_result_eelarve_taps) Or ;
		!Empty(l_result_eelarve_kassa_taps ) Or !Empty(l_result_eelarve_kassa )

	Replace rea_5 With 'Art. 100 ja vaba jäägi võrdlus ',;
		summa_51 With l_result_kassa,;
		summa_52 With l_result_saldo,;
		summa_53 With l_result_eelarve ,;
		summa_55 With l_result_eelarve_kassa ,;
		summa_56 With l_result_eelarve_kassa_taps,;
		summa_54 With l_result_eelarve_taps In kontrol_report
Endif


Select * From eelarve_report_query Order By idx, tegev, artikkel,  sub_idx  Into Cursor eelarve_report1

Clear

IF USED('eelarve_report_query')
	Use In eelarve_report_query
ENDIF


Select eelarve_report1


Function get_kontrol
	Lparameters l_idx, l_art, l_tegev, l_column
	l_return = 0

	Select Sum(kassa) As kassa, Sum(saldoandmik) As saldoandmik, Sum(eelarve) As eelarve,  ;
		sum(eelarve_kassa) As eelarve_kassa, Sum(eelarve_kassa_taps) As eelarve_kassa_taps,;
		sum(eelarve_taps) As eelarve_taps ;
		FROM eelarve_report_query ;
		WHERE (Alltrim(idx)+'-'+Str(idx1,1)+'-'+Str(sub_idx,1) = Iif(!Empty(l_idx), l_idx, Alltrim(idx)+'-'+Str(idx1,1)+'-'+Str(sub_idx,1)) And ;
		ALLTRIM(artikkel) = Iif(!Empty(l_art),l_art, artikkel) And ;
		ALLTRIM(tegev) = Iif(!Empty(l_tegev),l_tegev, tegev)) ;
		INTO Cursor tmp_formula

	If Reccount('tmp_formula') = 0
		Return 0
	Endif

	If l_column = 'kassa'
		l_return  = tmp_formula.kassa
	Endif

	If l_column = 'saldoandmik'
		l_return  = tmp_formula.saldoandmik
	Endif

	If l_column = 'eelarve'
		l_return  = tmp_formula.eelarve
	Endif
	If l_column = 'eelarve_kassa'
		l_return  = tmp_formula.eelarve_kassa
	Endif
	If l_column = 'eelarve_kassa_taps'
		l_return  = tmp_formula.eelarve_kassa_taps
	Endif
	If l_column = 'eelarve_taps'
		l_return  = tmp_formula.eelarve_taps
	Endif

	Return l_return

Endfunc

