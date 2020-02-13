LPARAMETERS tcParams
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
ENDIF

WAIT WINDOW 'P�ring...' nowait

lError = oDb.readFromModel('aruanned\eelarve\eelarve_andmik_lisa_1_5', 'eelarve_andmik_lisa_1_5_report', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'qryReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve t�itmine')
	Set Step On
	Select 0
	Return .F.
Endif



WAIT WINDOW 'Andmed, anal��s...' nowait

CREATE CURSOR eelarve_report_query (idx c(20), sub_idx integer, is_esita c(1) null, rekvid i, tegev c(20), artikkel c(20), nimetus c(254),;
	eelarve n(14,2) , tegelik n(14,2), kassa n(14,2), saldoandmik n(14,2))

* 3000+3030+3044+3045+3047

SELECT 'S' as is_esita, ;
	'2.1' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '30' as artikkel, UPPER('Maksutulud') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where LEFT(artikkel,4) IN ('3000','3030','3044','3045','3047') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

*	where artikkel in  ('3500','352','35200','35201') ;

SELECT 'S' as is_esita, ;
	'2.1' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '35' as artikkel, UPPER('Saadud toetused tegevuskuludeks') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where LEFT(artikkel,2) like  '35%' ;
	AND artikkel NOT in ('3502');
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1


*!*	SELECT 'S' as is_esita, ;
*!*		'2.1' as idx, 3 as sub_idx, gRekv as rekvid, space(20) as tegev, '350' as artikkel, UPPER('Muud saadud toetused tegevuskuludeks') as nimetus, ;
*!*		sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
*!*		FROM qryReport ;
*!*		where artikkel in  ('35200','35201') ;
*!*		INTO CURSOR tmp1

*!*	select eelarve_report_query 
*!*	append FROM DBF('tmp1')

*!*	USE IN tmp1


SELECT 'S' as is_esita, ;
	'2.1' as idx, 3 as sub_idx, gRekv as rekvid, space(20) as tegev, '38' as artikkel, UPPER('Muud tegevustulud ') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where artikkel  in ('382','3880','3888') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1


SELECT 'S' as is_esita, ;
	'2.1' as idx, 4 as sub_idx, gRekv as rekvid, space(20) as tegev, '4' as artikkel, UPPER('Antud toetused tegevuskuludeks') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where artikkel like '4%' ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

SELECT 'S' as is_esita, ;
	'2.1' as idx, 4 as sub_idx, gRekv as rekvid, space(20) as tegev, '5' as artikkel, UPPER('Muud tegevuskulud') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where LEFT(artikkel,2) in ('50','55','60') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1


*  30+32+35+38
SELECT 'S' as is_esita, ;
	'1.0' as idx, 0 as sub_idx, gRekv as rekvid, space(20) as tegev, space(20) as artikkel, UPPER('P�HITEGEVUSE TULUD KOKKU') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM eelarve_report_query ;
	where artikkel in ('30','32', '35','38') ;
	INTO CURSOR tmp_tulud_kokku

select eelarve_report_query 
append FROM DBF('tmp_tulud_kokku')


SELECT 'S' as is_esita, ;
	'2.1' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '4' as artikkel, UPPER('P�HITEGEVUSE KULUD KOKKU') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where (LEFT(artikkel,2) in ('50','55','60') OR artikkel like '4%') ;
	INTO CURSOR tmp_kulud_kokku

select eelarve_report_query 
append FROM DBF('tmp_kulud_kokku')


INSERT into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , tegelik , kassa, saldoandmik ) ;
VALUES ('2.3', 2, 'S', gRekv , space(20), '', UPPER('P�HITEGEVUSE TULEM') , ;
	(tmp_tulud_kokku.eelarve + tmp_kulud_kokku.eelarve),; 
	(tmp_tulud_kokku.tegelik + tmp_kulud_kokku.tegelik) , ;
	(tmp_tulud_kokku.kassa + tmp_kulud_kokku.kassa), ;
	(tmp_tulud_kokku.saldoandmik + tmp_kulud_kokku.saldoandmik) ) 


SELECT 'S' as is_esita, ;
	'2.4' as idx, 1 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('INVESTEERIMISTEGEVUS KOKKU') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(artikkel) in ('381', '15','3502','4502','1502','1501','1512','1511','1032','1531','655','650') ;
	INTO CURSOR investeerimis_tegevus

select eelarve_report_query 
append FROM DBF('investeerimis_tegevus')

INSERT into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , tegelik , kassa, saldoandmik ) ;
VALUES ('2.4.6', 1, 'S', gRekv , space(20), '', UPPER('EELARVE TULEM (�LEJ��K (+) / PUUDUJ��K (-))') , ;
	(tmp_tulud_kokku.eelarve + tmp_kulud_kokku.eelarve) + investeerimis_tegevus.eelarve,; 
	(tmp_tulud_kokku.tegelik + tmp_kulud_kokku.tegelik) + investeerimis_tegevus.tegelik , ;
	(tmp_tulud_kokku.kassa + tmp_kulud_kokku.kassa) + investeerimis_tegevus.kassa, ;
	(tmp_tulud_kokku.saldoandmik + tmp_kulud_kokku.saldoandmik) + investeerimis_tegevus.saldoandmik ) 


SELECT 'S' as is_esita, ;
	'2.4.6' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('FINANTSEERIMISTEGEVUS') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where LEFT(artikkel,4) in ('2585','2586') ;
	INTO CURSOR finants_tegenus

select eelarve_report_query 
append FROM DBF('finants_tegenus')


SELECT 'S' as is_esita, ;
	'2.4.8' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('N�UETE JA KOHUSTUSTE SALDODE MUUTUS (tekkep�hise e/a korral) (+/-)') as nimetus, ;
	(q.eelarve) - ((tmp_tulud_kokku.eelarve + tmp_kulud_kokku.eelarve) + investeerimis_tegevus.eelarve) + finants_tegenus.eelarve as eelarve, ;
	(q.tegelik) - ((tmp_tulud_kokku.tegelik + tmp_kulud_kokku.tegelik) + investeerimis_tegevus.tegelik) + finants_tegenus.tegelik as tegelik, ;
	(q.kassa) - ((tmp_tulud_kokku.kassa + tmp_kulud_kokku.kassa) + investeerimis_tegevus.kassa) + finants_tegenus.kassa  as kassa, ;
	(q.saldoandmik) - ((tmp_tulud_kokku.saldoandmik + tmp_kulud_kokku.saldoandmik) + investeerimis_tegevus.saldoandmik) + finants_tegenus.saldoandmik  as saldoandmik ;
	FROM qryReport q;
	where alltrim(artikkel) = ('100') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

*-- P�HITEGEVUSE KULUDE JA INVESTEERIMISTEGEVUSE V�LJAMINEKUTE JAOTUS TEGEVUSALADE J�RGI
* �ldised valitsussektori teenused


SELECT 'S' as is_esita, ;
	'3.1' as idx, 1 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('�ldised valitsussektori teenused') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('01111','01112','01800','01600','01700','01110','01120','01130','01210','01220','01310','01320','01330','01400','01500') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* 	IIF(ISNULL(q.eelarve),00000000.00,q.eelarve) as eelarve, q.tegelik, q.kassa, q.saldoandmik ;

SELECT IIF(EMPTY(q.is_e),'E','') as is_esita,  ;
	q.idx, 8 as sub_idx, q.rekvid, q.tegev, q.artikkel, q.nimetus, ;
	q.eelarve, q.tegelik, q.kassa, q.saldoandmik ;
	from qryReport q ;
	INTO cursor tmp2


select eelarve_report_query 

append FROM DBF('tmp2')

USE IN tmp2

* �lalnimetamata �ldised valitsussektori kulud kokku

UPDATE eelarve_report_query  ;
	SET idx = '3.1.0', sub_idx = 4 ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in  ('01110','01120','01130','01210','01220','01310','01320','01330','01400','01500') 

SELECT 'S' as is_esita, ;
	'3.1.0' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('�lalnimetamata �ldised valitsussektori kulud kokku') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('01110','01120','01130','01210','01220','01310','01320','01330','01400','01500') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Riigikaitse


UPDATE eelarve_report_query  ;
	SET idx = '3.1.1', sub_idx = 4, is_esita = 'E' ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in  ('02100','02200','02300','02400','02500') 

SELECT 'S' as is_esita, ;
	'3.1.1' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Riigikaitse') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('02100','02200','02300','02400','02500') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Avalik kord ja julgeolek

UPDATE eelarve_report_query  ;
	SET idx = '3.1.2', sub_idx = 4 ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in  ('03100','03200') 

SELECT 'S' as is_esita, ;
	'3.1.2' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Avalik kord ja julgeolek') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('03100','03200')  ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Muu avalik kord ja julgeolek kokku

UPDATE eelarve_report_query  ;
	SET idx = '3.1.2', ;
	sub_idx = 4, ;
	is_esita = 'E' ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in  ('03101','03300','03400','03500') 
	
* ,'03600'

SELECT 'S' as is_esita, ;
	'3.1.2' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Muu avalik kord ja julgeolek kokku') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('03101','03300','03400','03500','03600')   ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Majandus


UPDATE eelarve_report_query  ;
	SET idx = '3.1.3', ;
	sub_idx = 4 ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in  ('04120','04210','04220','04230','04350','04360','04510','04512','04520', '04540','04600','04710','04730','04740','04900') 

SELECT 'S' as is_esita, ;
	'3.1.3' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Majandus') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('04120','04210','04220','04230','04350','04360','04510','04512','04520', '04540','04600','04710','04730','04740','04900');
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* �lalnimetamata majandus kokku

UPDATE eelarve_report_query  ;
	SET idx = '3.1.4', ;
	sub_idx = 4, ;
	is_esita = 'E' ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870') 

SELECT 'S' as is_esita, ;
	'3.1.4' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('�lalnimetamata majandus kokku') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Keskkonnakaitse

UPDATE eelarve_report_query  ;
	SET idx = '3.1.5', ;
	sub_idx = 4 ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in ('05100','05200','05300','05400') 

SELECT 'S' as is_esita, ;
	'3.1.5' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Keskkonnakaitse') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('05100','05200','05300','05400');
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Muu keskkonnakaitse 

UPDATE eelarve_report_query  ;
	SET idx = '3.1.5', ;
	sub_idx = 6, ;
	is_esita = 'E' ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in ('05500','05600') 

SELECT 'S' as is_esita, ;
	'3.1.5' as idx, 5 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Muu keskkonnakaitse') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('05500','05600');
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Elamu- ja kommunaalmajandus

UPDATE eelarve_report_query  ;
	SET idx = '3.1.6', ;
	sub_idx = 4 ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in ('06100','06200','06300','06400','06500','06605') 

SELECT 'S' as is_esita, ;
	'3.1.6' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Elamu- ja kommunaalmajandus') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('06100','06200','06300','06400','06500','06605') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Tervishoid

UPDATE eelarve_report_query  ;
	SET idx = '3.1.7', ;
	sub_idx = 4, ;
	is_esita = IIF((ALLTRIM(tegev) = '07110' OR ALLTRIM(tegev) = '07400' OR ALLTRIM(tegev) = '07600'),'','E') ;
	WHERE ALLTRIM(idx) = '3.1' ;
	AND ALLTRIM(tegev) in ('07110','07230','07240','07320','07330','07400','07600','07120','07130','07500') 

* '07310','07340','07210','07220',


SELECT 'S' as is_esita, ;
	'3.1.7' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Tervishoid') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('07110','07210','07220','07230','07240','07310','07320','07330','07340','07400','07600','07120','07130','07500') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* �lalnimetamata tervishoid kokku

UPDATE eelarve_report_query  ;
	SET idx = '3.1.7', ;
	sub_idx = 4, ;
	is_esita = 'E' ;
	WHERE ALLTRIM(tegev) in ('07120','07130','07500') 

SELECT 'S' as is_esita, ;
	'3.1.7' as idx, 3 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('�lalnimetamata tervishoid kokku') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('07120','07130','07500')  ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Vaba aeg, kultuur ja religioon


UPDATE eelarve_report_query  ;
	SET idx = '3.1.8', ;
	sub_idx = 4 ;
	WHERE ALLTRIM(tegev) in ('08102','08103','08105','08106','08107','08108','08109','08201','08202','08203',;
		'08204','08205','08206','08207','08208','08209','08210','08211','08212','08300','08400','08500','08600') 

SELECT 'S' as is_esita, ;
	'3.1.8' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Vaba aeg, kultuur ja religioon') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('08102','08103','08105','08106','08107','08108','08109','08201','08202','08203',;
		'08204','08205','08206','08207','08208','08209','08210','08211','08212','08300','08400','08500','08600') ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Haridus

UPDATE eelarve_report_query  ;
	SET idx = '3.1.9', ;
	sub_idx = 4 ;
	WHERE ALLTRIM(tegev) in ('09110','09210','09211','09212','09220','09221','09222','09400','09500',;
		'09600','09601','09700','09800') 

SELECT 'S' as is_esita, ;
	'3.1.9' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Haridus') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('09110','09210','09211','09212','09220','09221','09222','09400','09500',;
		'09600','09601','09700','09800')  ;
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1

* Sotsiaalne kaitse


UPDATE eelarve_report_query  ;
	SET idx = '3.1.91', ;
	sub_idx = 4 ;
	WHERE ALLTRIM(tegev) in ('10110','10120','10121','10200','10201','10300','10400','10402','10500','10600',;	
		'10700','10701','10702','10800','10900') 

SELECT 'S' as is_esita, ;
	'3.1.91' as idx, 2 as sub_idx, gRekv as rekvid, space(20) as tegev, '' as artikkel, UPPER('Sotsiaalne kaitse') as nimetus, ;
	sum(eelarve) as eelarve, sum(tegelik) as tegelik, sum(kassa) as kassa, sum(saldoandmik) as saldoandmik ;
	FROM qryReport ;
	where alltrim(tegev) in ('10110','10120','10121','10200','10201','10300','10400','10402','10500','10600',;	
		'10700','10701','10702','10800','10900');
	INTO CURSOR tmp1

select eelarve_report_query 
append FROM DBF('tmp1')

USE IN tmp1



* MUUD N�ITAJAD 

INSERT into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , tegelik , kassa, saldoandmik ) ;
VALUES ('8.1', 0, 'N', gRekv , space(20), '', UPPER('MUUD N�ITAJAD ') , ;
	0,; 
	0, ;
	0, ;
	0 )

* Aasta alguse seisuga

INSERT into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , tegelik , kassa, saldoandmik ) ;
VALUES ('8.1', 1, 'N', gRekv , space(20), '', UPPER('Aasta alguse seisuga') , ;
	0,; 
	0, ;
	0, ;
	0 )


* Perioodi l�pu seisuga

INSERT into eelarve_report_query (idx , sub_idx, is_esita , rekvid, tegev, artikkel, nimetus ,;
	eelarve , tegelik , kassa, saldoandmik ) ;
VALUES ('8.2', 1, 'N', gRekv , space(20), '', UPPER('Perioodi l�pu seisuga') , ;
	0,; 
	0, ;
	0, ;
	0 )


USE IN qryReport

*!*		order by idx, tegev, artikkel ;
*!*		INTO CURSOR eelarve_report1 

SELECT * from eelarve_report_query ORDER BY idx, tegev, artikkel, sub_idx  INTO CURSOR eelarve_report1

USE IN eelarve_report_query

CLEAR

SELECT eelarve_report1
