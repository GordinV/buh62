Parameter tcWhere


l_cursor = 'curPalkOper'
l_output_cursor = 'palkoper_report1'

IF !USED('FLTRARUANNE')
	CREATE cursor fltrAruanne (kpv1 d default date (year (date()),month (date()),1),;
		kpv2 d default gomonth (fltrAruanne.kpv1,1) - 1,konto c(20), asutusId int, ametId int, osakondId int,;
		palkLibId int, Liik int, ametnik int DEFAULT 0, kond int )

	SELECT fltrAruanne
	APPEND blank

	IF USED('fltrPalkoper')
		replace kpv1 WITH fltrPalkoper.kpv1, kpv2 WITH fltrPalkoper.kpv2 IN fltrAruanne
	ENDIF
	
ENDIF


IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_cursor)
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> ORDER BY kpv, isik, nimetus into CURSOR <<l_output_cursor>>
ENDTEXT

&lcSql

IF !USED(l_output_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_output_cursor)

*!*	SET STEP ON 


*!*		tnIsik1 = 0
*!*		tnIsik2 = 999999999

*!*		tnLiik1 = 0
*!*		tnLiik2 = 999999999

*!*	SELECT 0

*!*	create cursor palkoper_report1 (liik int, kood c(20),mark c(3), nimetus c(254), journalid int, isik c(254), kpv d, summa y, kokku y, pank int, aa c(20), valuuta c(20))

*!*	if !empty (fltrAruanne.liik)
*!*		tnLiik1 = fltrAruanne.liik
*!*		tnLiik2 = fltrAruanne.liik
*!*	else
*!*		tnLiik1 = 0
*!*		tnLiik2 = 999999999
*!*	endif
*!*	dKpv1 = fltrAruanne.kpv1
*!*	dKpv2 = fltrAruanne.kpv2
*!*	if !empty (fltrAruanne.asutusId)
*!*		tnIsik1 = fltrAruanne.asutusId
*!*		tnIsik2 = fltrAruanne.asutusId
*!*	else
*!*		tnIsik1 = 0
*!*		tnIsik2 = 999999999
*!*	endif

*!*	tcKood = '%'

*!*	if !empty (fltrAruanne.palkLibId)
*!*		select compalkLib
*!*		locate for id = fltrAruanne.palkLibId
*!*		tcKood = compalkLib.kood
*!*	else
*!*		tcKood = '%'
*!*	endif

*!*	oDb.use ('QRYPALKOPER1')
*!*	sum (summa * kuurs) to lnKokku
*!*	select palkoper_report1
*!*	INSERT INTO palkOper_report1 (kood,  liik, mark, nimetus, isik, journalid, kpv, summa, pank, aa, valuuta);
*!*	SELECT kood, liik, mark, nimetus, isik, journalid, kpv, summa, pank, aa, valuuta;
*!*	FROM QRYPALKOPER1;
*!*	WHERE summa <> 0

*!*	*append from dbf ('QRYPALKOPER1')
*!*	use in QRYPALKOPER1
*!*	update palkoper_report1 set kokku = lnKokku
*!*	&&index on left(upper(isik),40)+'-'+dtoc(kpv,1) tag isik 
*!*	&&set order to isik