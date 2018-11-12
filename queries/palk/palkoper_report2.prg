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
