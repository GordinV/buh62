Parameter cWhere

IF !USED('curLadu')
	SELECT 0
	RETURN .f.
ENDIF
SELECT curLadu
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curLadu ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR ladu_report1
ENDTEXT

&lcSql

IF !USED('ladu_report1')
	SELECT 0
	RETURN .f.
ENDIF
SELECT ladu_report1
